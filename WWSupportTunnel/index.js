/*
 * Copyright (c) 2018, Arm Limited and affiliates.
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

var path = require('path');
var exec = require('child_process').exec;
var express = require('express');
var app = express();
var io = require('socket.io')(http);
var bodyParser = require('body-parser');
var WigWagUpdater = require('./wigwagupdater');
var http = require('http').Server(app);

// Values required for support
var randomPort = -1; // choose a random port on the support sever
var minPort = 19991; // smallest port number the client can reverse tunnel using
var maxPort = 19000; // biggest port number the client can reverse tunnel using
var port = 3000; // port of the current program
var supportIP = 'tunnel.wigwag.com'; // ip address of the server
var currentIP = '0.0.0.0';

// Values required for upgrades
wwUpdater = new WigWagUpdater({
    cloudURI: 'https://cloud.wigwag.com/apps/upgrade',
    stagingDirectory: '/updater/relay-updater/downloads',
    installDirectory: '/updater/relay-updater/installs',
    versionsFile: '/wigwag/etc/versions.json',
    relayInfoFile: '/wigwag/devicejs-core-modules/Runner/relay.config.json',
    infoModule: 'all-modules'
});

// ---- Upgrade section ---
app.get('/availableUpdates', function(req, res) {
    console.log('Available updates');
    wwUpdater.checkForUpdates().then(function(updatesAvailable) {
        res.status(200).send(updatesAvailable);
    }, function(error) {
        console.error('Error retrieving available updates:', error);
        res.status(500).send('Error retrieving available updates');
    });
});

app.get('/installedPackages', function(req, res) {
    res.status(200).send(wwUpdater.versions().packages);
});

app.post('/:packageName/install', function(req, res) {
    var packageName = req.params.packageName;

    wwUpdater.getCloudVersions().then(function(cloudVersions) {
        var packageData = WigWagUpdater.packageData(packageName, cloudVersions);

        if (packageData) {
            wwUpdater.downloadPackage(packageName, packageData.version).then(function() {
                return wwUpdater.installPackage(packageName, packageData.version);
            }).then(function() {
                res.status(200).send(packageData);
            }, function(error) {
                console.error('Error installing package:', error);
                res.status(400).send('Error installing package');
            });
        }
        else {
            console.error('No update available for package:', packageName);
            res.status(400).send('No update available');
        }
    }).then(function() {}, function(error) {
        console.error('Error retrieving available updates:', error);
        res.status(500).send('Error retrieving available updates');
    });
});

app.post('/:packageName/upgrade', function(req, res) {
    var packageName = req.params.packageName;

    wwUpdater.checkForUpdates().then(function(updatesAvailable) {
        console.log(updatesAvailable);
        var packageData = WigWagUpdater.packageData(packageName, {
            packages: updatesAvailable
        });

        if (packageData) {
            wwUpdater.downloadPackage(packageName, packageData.version).then(function() {
                return wwUpdater.installPackage(packageName, packageData.version);
            }).then(function() {
                res.status(200).send(packageData);
            }, function(error) {
                console.error('Error installing package:', error);
                res.status(400).send('Error installing package');
            });
        }
        else {
            console.error('No update available for package:', packageName);
            res.status(400).send('No update available');
        }
    }).then(function() {}, function(error) {
        console.error('Error retrieving available updates:', error);
        res.status(500).send('Error retrieving available updates');
    });
});

var updateInProgress = false;
app.post('/updateAll', function(req, res) {
    wwUpdater.checkForUpdates().then(function(updatesAvailable) {
        function installNextPackage(index) {
            if (index < updatesAvailable.length) {
                var updateAvailable = updatesAvailable[index]
                var packageName = updateAvailable.name;
                var packageVersion = updateAvailable.version;

                wwUpdater.downloadPackage(packageName, packageVersion).then(function() {
                    return wwUpdater.installPackage(packageName, packageVersion)
                }).then(function() {
                    installNextPackage(index + 1);
                }, function(error) {
                    console.error('Error installing packages:', error);
                    updateInProgress = false;
                    res.status(500).send('Error installing packages');
                });
            }
            else {
                updateInProgress = false;
                res.status(200).send(updatesAvailable);
            }
        }

        if (updateInProgress) {
            res.status(500).send('Update already in progress');
        }
        else {
            updateInProgress = true;
            installNextPackage(0);
        }
    }, function(error) {
        console.error('Error retrieving available updates:', error);
        res.status(500).send('Error retrieving available updates');
    });
});

app.post('/:packageName/uninstall', function(req, res) {
    var packageName = req.params.packageName;
    var packageData = WigWagUpdater.packageData(packageName, wwUpdater.versions());

    if (packageData) {
        wwUpdater.uninstallPackage(packageName, packageData.version).then(function() {
            res.status(200).send();
        }, function(error) {
            console.error('Error uninstalling package:', error);
            res.status(400).send('Error uninstalling package');
        });
    }
    else {
        console.error('Package not installed:', packageName);
        res.status(400).send('Package not installed');
    }
});

// --- Support Section ---                                                                 
function randomInt(low, high) {
    return Math.floor(Math.random() * (high - low)) + low;
}

function getSelfIPAddr() {
    var command = "ifconfig | grep eth0 -A 1 | awk '{ print $2 }' | grep addr:";
    var getSelfIP = exec(command, function(error, stdout, stderr) {
        currentIP = stdout.split(':')[1];
        console.log(currentIP);
        if (currentIP === undefined) {
            var command = "ifconfig | grep wlan0 -A 1 | awk '{ print $2 }' | grep addr:";
            var getSelfIP = exec(command, function(error, stdout, stderr) {
                currentIP = stdout.split(':')[1];
                console.log(currentIP);
            });
        }
    });
}

function startTunnel() {
    console.log('startTunnel');
    randomPort = randomInt(minPort, maxPort);
    var command = 'ssh -f -N -R ' + randomPort + ':localhost:22 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null support@' + supportIP + ' -i /wigwag/support/relay_support_key';
    var sshSupport = exec(command, function(error, stdout, stderr) {
        console.log("Ended Support Tunnel");
    });
}

function killTunnel() {
    // get the PIDs of every process associated with tunneling
    var command = "ps ax | grep 'ssh -f -N -R' | awk '{ print $5" + '" "' + "$1 }'"
    var getPIDs = exec(command, function(error, stdout, stderr) {
        // get the tuple of {command, pid}
        var pidCommands = stdout.split('\n')
        for (var i = 0; i < pidCommands.length; i++) {
            var pair = pidCommands[i];
            var thing = pair.split(' ');
            if (thing[0] === 'ssh') {
                command = 'kill ' + thing[1];
                var killTun = exec(command, function(error, stdout, stderr) {
                    console.log(command + " - killed tunnel");
                    killingTunnel = false;
                });
            }
        }
    });
    console.log('Killed All Tunnels');
}

function generateKey() {
    console.log('generate key');
    // create .ssh directory for support, ignore error if already exists    
    var command = 'mkdir /home/support/.ssh';
    var mkdirSSH = exec(command, function(error, stdout, stderr) {
        // remove all files (private key, public key, "public/" folder) that already may be there             
        command = 'rm -rf /home/support/.ssh/id_rsa* && rm -rf /home/support/.ssh/authorized_keys';
        var removeSSH = exec(command, function(error, stdout, stderr) {
            // generate private and public keys for support
            command = 'ssh-keygen -t rsa -N "" -f /home/support/.ssh/id_rsa';
            var genSSH = exec(command, function(error, stdout, stderr) {
                // create "public/" folder for exposure to user
                command = 'cp /home/support/.ssh/id_rsa /wigwag/support/public';
                var cpPrivate = exec(command, function(error, stdout, stderr) {
                    // add public key to authorized_keys files       
                    command = 'cat /home/support/.ssh/id_rsa.pub >> /home/support/.ssh/authorized_keys';
                    var authSSH = exec(command, function(error, stdout, stderr) {
                        console.log('finished generating keys');
                    });
                });
            });
        });
    });
}

function rejectedPromise(callingFunction) {
    console.log('promise rejected: ' + callingFunction);
}

function removeKeys() {
    var command = 'rm -rf /home/support/.ssh/id_rsa*  && rm -rf /home/support/.ssh/authorized_keys && rm /wigwag/support/public/id_rsa';
    var removeSSH = exec(command, function(error, stdout, stderr) {
        console.log('removed keys');
    });
}

function getStart() {
    // both of these functions happen asynchronously, but that's okay. They do not depend on each other
    startTunnel(); // start tunnel to cloud support
    generateKey(); // generate keys to client-relay, so server-support can tunnel to relay
}

function getStop() {
    console.log('stopping tunnel');
    randomPort = -1;

    killTunnel();
    removeKeys();
}

function copyKnownHosts() {
    var command = "cat /home/root/.ssh/known_hosts | grep " + supportIP;
    var checkKH = exec(command, function(error, stdout, stderr) {
        if (stdout === undefined || stdout == "") {
            var command = "cat /wigwag/support/known_hosts >> /home/root/.ssh/known_hosts";
            var copyHosts = exec(command, function() {
                console.log("known hosts copied to root/.ssh");
            });
        }
    });
}

function chownSupport() {
    var command = "chown -R support:support /home/support/.ssh";
    var chownSup = exec(command, function(error, stdout, stderr) {
        console.log("changed the ownership of support/.ssh");
    });
}

function chmodRelaySupportKey() {
    var command = "chmod 600 /wigwag/support/relay_support_key";
    var chownSup = exec(command, function(error, stdout, stderr) {
        console.log("change permissions of relay_support_key");
    });
}

function mainBody() {
    console.log('Support Tunnel web interface starting');
    getStop();
    getSelfIPAddr();
    chownSupport();
    copyKnownHosts();
    chmodRelaySupportKey();

    app.get('/', function(req, res) {
        req.socket.on("error", function() {});
        res.socket.on("error", function() {});
        res.redirect('index.html');
    });

    app.get('/returnPort', function(req, res) {
        res.status(200).send("" + randomPort);
    });

    app.get('/returnKey', function(req, res) {
        var command = 'cat /home/support/.ssh/id_rsa';
        var displaySSH = exec(command, function(error, stdout, stderr) {
            res.status(200).send(stdout);
        });
    });

    app.get('/start', function(req, res) {
        chmodRelaySupportKey();
        copyKnownHosts();
        getStart();
        res.status(200).send();
    });

    app.get('/stop', function(req, res) {
        getStop();
        res.status(200).send();
    });

    app.get('/downloadKey', function(req, res) {
        var file = path.join(__dirname, "/public/id_rsa");
        res.download(file);
    });

    // serve static files out of ./public as well
    app.use(express.static(path.join(__dirname, 'public')));

    io.on('connection', function(socket) {
        console.log("someone connected");
        socket.on('disconnect', function() {
            console.log('stopping tunnel');
            console.log('user disconnected');
            randomPort = -1;
            killTunnel();
            removeKeys();
        });
    });

    http.listen(port, function() {
        console.log('supportTunnel listening on ' + currentIP + ':' + port);
    });

}

mainBody();