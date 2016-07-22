var util = require('util');
var path = require('path');
var http = require('http');
var url = require('url');
var fs = require('fs');
var crypto = require('crypto');
var JSONminify = require('jsonminify');
var lockFile = require('lockfile');
var child_process = require('child_process');
var tarball = require('tarball-extract');
var rimraf = require('rimraf');
var DeviceJSUpdater = require('./devjsupdater');
var request = require('request');

var WigWagUpdater = function(options) {
    DeviceJSUpdater.call(options);

    if(typeof options !== 'object') {
        options = { };
    }

    try {
        this._cloudURI = url.parse(options.cloudURI);
    }
    catch(error) {
        // default to cloud.wigwag.com
        this._couldURI = url.parse('http://cloud.wigwag.com/apps/upgrade');
    }

    try {
        this._infoModule = options.infoModule;
        console.log("this._infoModule = ", this._infoModule);
    }
    catch(error) {
        // default to all-modules
        this._infoModule = 'all-modules';
    }

    if(typeof options.stagingDirectory !== 'string') {
        throw new TypeError('options.stagingDirectory must be a file path');
    }
    else {
        if(fs.existsSync(options.stagingDirectory)) {
            this._stagingDirectory = options.stagingDirectory;
        }
        else {
            throw new Error('Staging directory does not exist: ' + options.stagingDirectory);
        }
    }

    if(typeof options.installDirectory !== 'string') {
        throw new TypeError('options.installDirectory must be a file path');
    }
    else {
        if(fs.existsSync(options.installDirectory)) {
            this._installDirectory = options.installDirectory;
        }
        else {
            throw new Error('Install directory does not exist: ' + options.installDirectory);
        }
    }

    try {
        var versionsFileContents = fs.readFileSync(options.versionsFile);
        this._versionsFile = JSON.parse(versionsFileContents);
        this._versionsFilePath = options.versionsFile;
    }
    catch(error) {
        if(error.code === 'ENOENT') {
            throw new TypeError('Could not open versions file: ' + options.versionsFile);
        }
        else if(error.name === 'SyntaxError') {
            throw new Error('Could not parse versions file: ' + options.versionsFile);
        }
        else {
            throw error;
        }
    }

    try {
        this._relayInfoFilePath = options.relayInfoFile;
        var relayConfig = this.getRelayConfig(this._relayInfoFilePath);
        this._relayID = relayConfig.relayID;
        this._cloudURI = url.parse(relayConfig.cloudURL + "/apps/upgrade");
    }
    catch(error) {
        if(error.code === 'ENOENT') {
            throw new TypeError('Could not open relay info file: ' + options.relayInfoFile);
        }
        else if(error.name === 'SyntaxError') {
            throw new Error('Could not parse relay info file: ' + options.relayInfoFile);
        }
        else {
            throw error;
        }
    }

};

util.inherits(WigWagUpdater, DeviceJSUpdater);

WigWagUpdater.prototype.getRelayConfig = function(confFile) {

    try {

        var retValues = {};
        var processGroup = this._infoModule;
        var jscontents = JSON.parse(JSONminify(fs.readFileSync(confFile, 'utf8')));

        for (var i=0;i<jscontents.process_groups[processGroup].modules.length; i++) {
            if (jscontents.process_groups[processGroup].modules[i].path.match(/wigwag-devices/) != undefined) {
                retValues.cloudURL = jscontents.process_groups[processGroup].modules[i].config.cloudURL;
                retValues.relayID = jscontents.process_groups[processGroup].modules[i].config.apiKey;
                return retValues;
            }
        }
    }
    catch (error) {
        console.log('Unable to obtain relayID cloudURL the relay configuration file', confFile, error);
        return 'UNKNOWN';
    }
}

function mkdir(directory) {
    return new Promise(function(resolve, reject) {
        fs.mkdir(directory, function(error) {
            if(error) {
                reject(error);
            }
            else {
                resolve();
            }
        });
    });
}

function extractPackageTarball(stagingDirectory, installDirectory, packageName, version) {
    var packageFileName = packageName + '-' + version + '.tar.gz';
    var archiveFilePath = path.join(stagingDirectory, packageFileName);
    var extractedPath = path.join(installDirectory, packageName);

    console.log('Deleting', extractedPath);
    return rmrf(extractedPath).then(function() {
        return mkdir(extractedPath)
    }).then(function() {
        return new Promise(function(resolve, reject) {
            console.log('Extracting', archiveFilePath, 'to', extractedPath);

            var extract = child_process.spawn('tar', [ '-xvf', archiveFilePath, '-C', extractedPath ], { stdio: 'inherit' });

            extract.on('close', function(code) {
                console.log('Done extracting', 'Exit code:', code);
                if(code == 0) {
                    resolve();
                }
                else {
                    reject(new Error('Extract exited with code ' + code));
                }
            });
            /*tarball.extractTarball(archiveFilePath, extractedPath, function(error) {
                if(error) {
                    reject(error);
                }
                else {
                    resolve();
                }
            });*/
        }).then(function() {
            console.log('Deleting', archiveFilePath, '...');
            return rmrf(archiveFilePath);
        });
    });
}

function rmrf(directory) {
    return new Promise(function(resolve, reject) {
        rimraf(directory, function(error) {
            if(error) {
                reject(error);
            }
            else {
                resolve();
            }
        });
    });
}

function exists(file) {
    return new Promise(function(resolve, reject) {
        fs.exists(file, function(exists) {
            resolve(exists);
        });
    });
}

// runs specified script if it exists
function runPackageScript(packageDirectory, scriptName) {
    var command = path.join(packageDirectory, scriptName);

    return exists(command).then(function(fileExists) {
        if(fileExists) {
            console.log('Running script', command, '...');
            return new Promise(function(resolve, reject) {
                var installScript = child_process.spawn('sh', [ command ], { stdio: 'inherit' });

                installScript.on('close', function(code) {
                    console.log('Done running script', command, 'Exit code:', code);
                    if(code == 0) {
                        resolve();
                    }
                    else {
                        reject(new Error(command + ' exited with code ' + code));
                    }
                })
            });
        }
        else {
            console.log('Script does not exist', packageDirectory, 'skipping...');
        }
    });
}

function runInstallScript(packageDirectory) {
    return runPackageScript(packageDirectory, 'install.sh');
}

function runPostInstallScript(packageDirectory) {
    return runPackageScript(packageDirectory, 'post-install.sh');
}

function runUninstallScript(packageDirectory) {
    return runPackageScript(packageDirectory, 'uninstall.sh');
}

// does all the work of uninstalling a package without updating the versions file
function uninstallPackage(installDirectory, packageName, version) {
    var destinationDir = path.join(installDirectory, packageName);

    return runUninstallScript(destinationDir).then(function() {
        console.log('Remove old package', destinationDir);
        return rmrf(destinationDir);
    });
}

function indexOfPackage(vObj, name) {
    for (var i=0; i< vObj.packages.length; i++) {
        if (vObj.packages[i].name === name) {
            return i;
        }
    }
    return -1;
}

function updatePackageVersion(versions, packageName, version, cloudVersions) {
    var index = indexOfPackage(versions, packageName);
    var cloudIndex = indexOfPackage(cloudVersions, packageName);

    if(cloudIndex != -1) {
        console.log('Updating package information for', packageName);
        var cloudPackageData = cloudVersions.packages[cloudIndex];

        if(index != -1) {
            console.log('Replace old package information', cloudPackageData);
            versions.packages[index] = cloudPackageData;
        }
        else {
            console.log('Add new package information', cloudPackageData);
            versions.packages.push(cloudPackageData);
        }
    }
}

function removePackageVersion(versions, packageName, version) {
    var index = indexOfPackage(versions, packageName);

    if(index != -1) {
        console.log('Remove package information', packageName);
        versions.packages.splice(index, 1);
    }
}

function saveVersionsFile(versionsFile, versionsObject) {
    return new Promise(function(resolve, reject) {
        console.log('Saving versions file', versionsFile, '...');
        fs.writeFile(versionsFile, JSON.stringify(versionsObject, null, 4), function(error) {
            if(error) {
                console.log('Unable to save versions file', versionsFile, error.stack);
                reject(error);
            }
            else {
                console.log('Saved versions file', versionsFile);
                resolve();
            }
        });
    });
}

// Package is already installed. Needs to be uninstalled/removed from versions file
WigWagUpdater.prototype.uninstallPackage = function(packageName, version) {
    var versions = this._versionsFile;
    var versionsFilePath = this._versionsFilePath;
    var installDirectory = this._installDirectory;
    var lockPath = path.join(this._stagingDirectory, 'ww-packages-lock');//packageName.lock);

    return fileLock(lockPath, { wait: 60000 }).then(function() {
        return uninstallPackage(installDirectory, packageName, version);
    }).then(function() {
        removePackageVersion(versions, packageName, version);
        return saveVersionsFile(versionsFilePath, versions);
    }).then(function() {
        return fileUnlock(lockPath);
    }, function(error) {
        return fileUnlock(lockPath).then(function() {
            throw error;
        });
    });
};

WigWagUpdater.packageData = function(packageName, versionsInfo) {
    function indexOfPackage(vObj, name) {
        for (var i=0; i< vObj.packages.length; i++) {
            if (vObj.packages[i].name === name) {
                return i;
            }
        }
        return -1;
    }

    var index = indexOfPackage(versionsInfo, packageName);

    if(index == -1) {
        return null;
    }
    else {
        return versionsInfo.packages[index];
    }

};

WigWagUpdater.prototype.versions = function() {
    return this._versionsFile;
};

function fileLock(lockPath, lockOpts) {
    lockOpts = lockOpts || { };

    return new Promise(function(resolve, reject) {
        console.log('Acquiring file lock', lockPath, '...');
        lockFile.lock(lockPath, lockOpts, function(error) {
            if(error) {
                console.log('Could not acquire file lock', lockPath, error.stack);
                reject(error);
            }
            else {
                console.log('Acquired file lock', lockPath);
                resolve();
            }
        });
    });
}

function fileUnlock(lockPath) {
    return new Promise(function(resolve, reject) {
        console.log('Releasing file lock', lockPath, '...');
        lockFile.unlock(lockPath, function(error) {
            if(error) {
                console.log('Could not release file lock', lockPath, error.stack);
                reject(error);
            }
            else {
                console.log('Released file lock', lockPath);
                resolve();
            }
        });
    });
}

WigWagUpdater.prototype.installPackage = function(packageName, version) {
    var sourceDir = path.join(this._stagingDirectory, packageName);
    var lockPath = path.join(this._stagingDirectory, 'ww-packages-lock');//packageName.lock);
    var installDir = this._installDirectory;
    var destinationDir = path.join(installDir, packageName);
    var versions = this._versionsFile;
    var versionsFilePath = this._versionsFilePath;
    var cloudVersions = null;
    var stagingDirectory = this._stagingDirectory;

    console.log('Installing package:', packageName, 'version:', version);
    return this.getCloudVersions().then(function(cv) {
        cloudVersions = cv;
        return fileLock(lockPath, { wait: 60000 });
    }).then(function() {
        return extractPackageTarball(stagingDirectory, stagingDirectory, packageName, version);
    }).then(function() {
        // removes old version of package if needed
        return uninstallPackage(installDir, packageName, version);
    }).then(function() {
        return new Promise(function(resolve, reject) {
            console.log('Renaming', sourceDir, 'to', destinationDir, '...');
            fs.rename(sourceDir, destinationDir, function(error) {
                if(error) {
                    console.log('Could not rename', sourceDir, 'to', destinationDir, error.stack);
                    reject(error);
                }
                else {
                    console.log('Renamed', sourceDir, 'to', destinationDir);
                    resolve();
                }
            });
        });
    }).then(function() {
        return runInstallScript(destinationDir);
    }).then(function() {
        updatePackageVersion(versions, packageName, version, cloudVersions);
        return saveVersionsFile(versionsFilePath, versions);
    }).then(function() {
        return runPostInstallScript(destinationDir);
    }).then(function() {
        return fileUnlock(lockPath);
    }, function(error) {
        return fileUnlock(lockPath).then(function() {
            throw error;
        });
    });
};

// Download package
WigWagUpdater.prototype.downloadPackage = function(packageName, version) {
    var cloudURI = this._cloudURI;
    var packageFileName = packageName + '-' + version + '.tar.gz';
    var packageFilePath = path.join(cloudURI.path, 'packages', packageName, packageFileName);
    var packageURI = url.resolve(cloudURI.href, packageFilePath);
    var stagingDirectory = this._stagingDirectory;

    return new Promise(function(resolve, reject) {
        console.log('Downloading package from cloud', packageURI);

        request.get(packageURI).on('response', function(res) {
            if(res.statusCode == 200) {
                var archiveWriteStream = fs.createWriteStream(path.join(stagingDirectory, packageFileName));

                res.pipe(archiveWriteStream);

                archiveWriteStream.on('finish', function() {
                    archiveWriteStream.close(function() {
                        console.log('Downloaded package from cloud', packageURI);
                        resolve();
                    })
                }).on('error', function(error) {
                    console.log('Unable to download package from cloud', packageURI, error);
                    reject(error);
                });
            }
            else {
                console.log('Unable to download package from cloud', packageURI, res.statusCode);
                reject(new Error('Could not retrieve file: ' + packageFileName));
            }
        }).on('error', function(error) {
            console.log('Unable to download package from cloud', packageURI, error);
            reject(error);
        });
    });
};

WigWagUpdater.prototype.getCloudTime = function() {
    
    var timeURI = url.resolve(this._cloudURI.href, path.join(this._cloudURI.pathname, 'time'));

    console.log("**");
    console.log("timeURI = ",  timeURI);
    console.log("**");

    return new Promise(function(resolve, reject) {
        request.get({
            uri: timeURI,
            json: true
        }, function(error, response, body) {
            if(error) {
                reject(error);
            }
            else {
                try {
                    if(typeof body === 'object') {
                        var time = body.time;
                    }
                    else {
                        throw new Error('Unable to parse body');
                    }

                    resolve(time);
                }
                catch(error) {
                    reject(error);
                }
            }
        });
    });
};

WigWagUpdater.prototype.getCloudVersions = function() {
    /*var versionsURI = {
        hostname: this._cloudURI.hostname,
        path: path.join(this._cloudURI.path, '/versions.json'),
        port: this._cloudURI.port
    };*/
    var versionsURI = url.resolve(this._cloudURI.href, path.join(this._cloudURI.pathname, 'versions.json'));

    return new Promise(function(resolve, reject) {
        console.log('Get package versions info from cloud...', versionsURI);

        request.get({
            uri: versionsURI,
            json: true
        }, function(error, response, body) {
            if(error) {
                console.log('Unable to get package versions info from cloud', versionsURI, error);
                reject(error);
            }
            else {
                try {
                    if(typeof body === 'object') {
                        var cloudVersions = body;
                    }
                    else {
                        throw new Error('Unable to parse body');
                    }

                    console.log('Got package versions info from cloud', versionsURI);
                    resolve(cloudVersions);
                }
                catch(error) {
                    console.log('Unable to get package versions info from cloud', versionsURI, error);
                    reject(error);
                }
            }
        });
    });
};

WigWagUpdater.prototype.checkForUpdates = function() {
    var relayID = ''+this._relayID;
    var currentTime;
    var that = this;

    /**
       Returns the index into the vObj of packaged named 'name'
       **/
    function indexOfPackage(vObj, name) {
        for (var i=0; i< vObj.packages.length; i++) {
            if (vObj.packages[i].name === name) {
                return i;
            }
        }
        return -1;
    }

    /**
       Parses a 3 digit version number and compares them
        Returns true of ver2 is greater than ver1
        **/
    function isVersionGreater(ver1, ver2) {

        var vArray1 = ver1.split('.');
        var vArray2 = ver2.split('.');

        if (parseInt(vArray1[0]) > parseInt(vArray2[0])) {
            return true;
        } else if (parseInt(vArray1[1]) > parseInt(vArray2[1])) {
            return true;
        } else if (parseInt(vArray1[2]) > parseInt(vArray2[2])) {
            return true;
        } else {
            return false;
        }
    }

    function getOutOfDatePackageList(local, cloud) {
        var requiresUpgrade = [];

        console.log('comparing package versions for new updates');
        console.log('local', local);
        console.log('cloud', cloud);

        for (var i=0; i<local.packages.length; i++) {
            cloudIndex = indexOfPackage(cloud, local.packages[i].name);

            if (cloudIndex !== -1) {
                if( (isVersionGreater(cloud.packages[cloudIndex].version, local.packages[i].version)) ||
                    (cloud.packages[cloudIndex].node_module_hash !== local.packages[i].node_module_hash) ||
                    (cloud.packages[cloudIndex].ww_module_hash !== local.packages[i].ww_module_hash) ) {
                        requiresUpgrade.push(cloud.packages[cloudIndex]);
                }
            }
        }
        return requiresUpgrade;
    }

    function getNewPackageList(local, cloud) {
        var newPackages = [];

        console.log('comparing package versions for uninstalled updates');
        console.log('local', local);
        console.log('cloud', cloud);

        for (var i=0; i<cloud.packages.length; i++) {
            localIndex = indexOfPackage(local, cloud.packages[i].name);

            if (localIndex === -1) {
                newPackages.push(cloud.packages[i]);
            }
        }

        return newPackages;
    }

    function filterByReleaseStrategy(packageInfo) {
        if(typeof packageInfo.releaseStrategy === 'object') {
            if(packageInfo.releaseStrategy.partitionType === 'bucket') {
                if(typeof packageInfo.releaseStrategy.partitionOptions === 'object') {
                    var bucketCount = packageInfo.releaseStrategy.partitionOptions.bucketCount;
                    var startTime = packageInfo.releaseStrategy.partitionOptions.startTime;
                    var staggerPeriod = packageInfo.releaseStrategy.partitionOptions.staggerPeriod;

                    return filterBucketRelease(bucketCount, startTime, staggerPeriod, currentTime);
                }
            }
            else if(packageInfo.releaseStrategy.partitionType === 'ranged') {
                if(typeof packageInfo.releaseStrategy.partitionOptions === 'object') {
                    if(packageInfo.releaseStrategy.partitionOptions.ranges instanceof Array) {
                        var ranges = packageInfo.releaseStrategy.partitionOptions.ranges;

                        return filterRanges(ranges, currentTime);
                    }
                }
            }
        }

        return true;
    }

    function filterBucketRelease(bucketCount, startTime, staggerPeriod, currentTime) {
        var md5sum = crypto.createHash('md5');
        var myBucketID = md5sum.update(relayID).digest().readUInt32LE(0) % bucketCount;
        var latestReleaseBucket = Math.min(parseInt((new Date(currentTime).getTime()-new Date(startTime).getTime())/staggerPeriod), bucketCount-1);

        console.log(
            'Filter Bucket Release\n' +
            '  Bucket Count:   %d\n' +
            '  Start Time:     %d\n' +
            '  Stagger Period: %d\n' +
            '  Current Time:   %d\n' +
            '  My Bucket ID:   %d\n' +
            '  Latest Bucket:  %d\n', bucketCount, startTime, staggerPeriod, currentTime, myBucketID, latestReleaseBucket);

        return myBucketID <= latestReleaseBucket;
    }

    function filterRanges(ranges, currentTime) {
        console.log('Filter ranges', ranges);

        return ranges.filter(function(range) {
            var match_result = false; // default to no match
            try {
                var pattern = new RegExp(range.pattern);
                match_result = relayID.match(pattern);
            } catch(err) {
                console.error("Server range pattern ( " + range.patten + " ) is invalid: " + err + " No Upgrade possible")
            }
            return match_result;
        }).reduce(function(previousValue, currentValue) {
            return previousValue || (new Date(currentTime).getTime() >= new Date(currentValue.releaseTime).getTime());
        }, false);
    }

    return new Promise(function(resolve,reject){

    	that.getCloudTime().then(function(cloudTime) {
    	    currentTime = cloudTime;
    	    return this.getCloudVersions();
    	}.bind(that), function(error) {
            throw(error);
    	}).then(function(cloudVersions) {
    	    var localVersions = that._versionsFile;
    	    var upgradablePackages = getOutOfDatePackageList(localVersions, cloudVersions);
    	    var uninstalledPackages = getNewPackageList(localVersions, cloudVersions);

            console.log("upgradablePackages = " + util.inspect(upgradablePackages));
            console.log("uninstalledPackages = " + util.inspect(uninstalledPackages));
    	    uninstalledPackages.forEach(function(p) {
    		upgradablePackages.push(p);
    	    });

    	    return upgradablePackages;
    	}).then(function(upgradablePackages) {
    	    console.log('FILTER', upgradablePackages);
    	    return resolve(upgradablePackages.filter(filterByReleaseStrategy));
    	}).catch(function(error) {
    	    console.log("error checking for updates: " + error);
    	    return reject(error);
    	});
    });
};

module.exports = WigWagUpdater;

