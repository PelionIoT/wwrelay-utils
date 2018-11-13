const http = require("http")
const express = require('express');
const WebSocket = require('ws');
const uuid = require("uuid");
const readline = require('readline');
const fs = require('fs')
const util = require('util')
var exec = require('child_process').exec;
var spawn = require('child_process').spawn;
var help = require('./utils/helpCommand');
var chalk = require('chalk')

connectedClinet = []

var version = "1.0.0"


var allcommands = 'getRelay getAllRelays upgradeAllRelaysWithUrl upgradeRelayWithUrl runCommandOnGW  led'
+' restartAllMaestro restartMaestro getAllUpgrade getUpgrade killAllUpgrade killUpgrade upgradeGateway'
+' downloadBuild clearBuild '

function completer(line) {
    var completions = allcommands;
    completions = completions.split(' ');
    const hits = completions.filter((c) => c.startsWith(line));
    // show all completions if none found
    return [hits.length ? hits : completions, line];
}

var cmdHistory = function (rpl, file) {
    var fd = fs.openSync(file, 'a')
    try {
        var stat = fs.statSync(file);
        rpl.history = fs.readFileSync(file, 'utf-8').split('\n').reverse();
        rpl.history.shift();
        rpl.historyIndex = -1; // will be incremented before pop
    } catch (e) {
        console.log("Error: ", e)
    }

    var wstream = fs.createWriteStream(file, {
        fd: fd
    });
    wstream.on('error', function(err) {
        throw err;
    });
    rpl.addListener('line', function(code) {
        if (code && code !== '.history'/* && inputflag == false && code !== 'yes' && code !== 'no'*/) {
          wstream.write(code + '\n');
        } else {
            // console.log('pop ', repl.rli);
          // rpl.rli.historyIndex++;
          // rpl.rli.history.pop();
        }
    });
}

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: 'GK> ',
    completer: completer
})

cmdHistory(rl,process.env.HOME+'/.gk_history')

var app = express();
const port = 3232
process.setMaxListeners(0)
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

wss.on('connection', function connection(ws,req) {
    ws.id = uuid.v4();
    ws.send(ws.id+"_id");

    ws.on('message', function incoming(data) {
        //console.log(data)
        if(data.indexOf('SCPIP') > -1) {
            process.stdout.write('Copying...')
            let timer = setInterval(function() { process.stdout.write('.'); }, 500);
            var cliArgv = data.split(' ')
            var IP = cliArgv[1]
            var build = cliArgv[2]
            if(data.indexOf("ARMSCPIP") > -1) {
                cmd = "./debug_script/expect-ssh-copy.sh " + IP + " arm-" + build
            } else {
                cmd = "./debug_script/expect-ssh-copy.sh " + IP + " " + build
            }
            exec(cmd,function(error, stdout, stderr) {
                if(error) {
                    console.log('failed to copy')
                }
                clearInterval(timer)
                console.log(stdout)
            })
        } else if(data.indexOf('openInfo') > -1){
                connectedClinet.push(JSON.parse(data.split(':-')[1]))
        } else if(data.indexOf('closeInfo') > -1) {
            for(var i = 0; i <= connectedClinet.length - 1; i++) {
                console.log(JSON.parse(data.split(':-')[1]))
                if(connectedClinet[i].relayID == JSON.parse(data.split(':-')[1]).relayID) {
                    connectedClinet.splice(i, 1); 
                }
            }
        }else {
            console.log(data)
        }
    })
});

// rl.prompt()
rl.on('line', (line) => {
    console.log(chalk.yellow.bold("Total webSocket is " + wss.clients.size))
    if(line.indexOf('-h') > -1) {
        var command = line.split(' ')[0]
        if(help[command]) {
            console.log(chalk.blue.bold(command) ,
                        '\n\t',chalk.bold('Usage:'),
                        '\n\t\t',help[command].Usage,
                        '\n\t',chalk.bold('Description:'),
                        '\n\t\t',help[command].Description)
            rl.prompt()
        }
    } else if(line.indexOf('downloadBuild') > -1){
        var cliArgv = line.split(' ')
        var build = cliArgv[1]
        var cloudbasename = cliArgv[2]
        let bufferStream = '';
        let errorStream = '';
        var command = ''
        if(cloudbasename == 'arm') {
            command = "sudo wget -O "+__dirname+"/build/arm-"+build+"-field-factoryupdate.tar.gz https://code.wigwag.com/ugs/builds/arm_development/cubietruck/"+build+"-field-factoryupdate.tar.gz --no-check-certificate"   
        } else{
            command = "sudo wget -O "+__dirname+"/build/"+build+"-field-factoryupdate.tar.gz https://code.wigwag.com/ugs/builds/development/cubietruck/"+build+"-field-factoryupdate.tar.gz --no-check-certificate"
     
        }
        var child = exec(command, {maxBuffer: 1024 * 500},function(error, stdout, stderr) {
            if(error) {
                console.log(chalk.red.bold('failed to copy ==> '+error))
                //console.log('failed to copy ==> '+error)
            }
            //if (self.verbose) {
            
        //}
        })
        child.stdout.on('data', data => {
                // console.log('[STR] stdout "%s"', String(data));
                const getData = data.split(' ')
                const status = getData.filter((c) => c.endsWith("%"));
                const size = getData.filter((c) => c.endsWith("M"));
                const eta = getData.filter((c) => c.endsWith("s"));
                //console.log(status[0])
                if(status[0] === undefined || size[0] === undefined || eta[0] === undefined)return 0;
                //printProgress(status[0], size[0], eta[0], "102.0.380-field-factoryupdate.tar.gz")
                //console.log('\u001b[2J\u001b[0;0H')
                process.stdout.clearLine();
                process.stdout.cursorTo(0);
                process.stdout.write("[ Downloading Build                                        "+ data + ' ]');
                bufferStream += data;
            });

            child.stderr.on('data', error => {
                //console.log('[STR] stdout "%s"', String(error));
                var getData = error.split(' ')
                var status = getData.filter((c) => c.endsWith("%"));
                const size = getData.filter((c) => c.endsWith("M"));
                const eta = getData.filter((c) => c.endsWith("s"));
                //console.log(status[0])
                if(status[0] === undefined || size[0] === undefined || eta[0] === undefined)return 0;
                 //console.log('\u001b[2J\u001b[0;0H')
                process.stdout.clearLine();
                process.stdout.cursorTo(0);
                process.stdout.write("[ Downloading Build                                        "+ error + ' ]');
                //printProgress(status[0], size[0], eta[0], "102.0.380-field-factoryupdate.tar.gz")
                errorStream += error;
            });
            child.on('close', code => {
                console.log(chalk.blue.bold("\nDownloading finished"))
                rl.prompt()
            })
    } else if(line.indexOf('clearBuild') > -1) {
        var command = "rm -rf "+__dirname+"/build/*"
        exec(command,function(error, stdout, stderr) {
            if(error) {
                console.log('failed to remove'+error)
            }
            console.log("Build folder is clean.")
            rl.prompt()
        })
    }
    // else if(line.indexOf('login') > -1) {
    //     var cliArgv = line.split(' ')
    //     var cmd = cliArgv[0]
    //     var IP = cliArgv[1]
    //     var command = __dirname+'/debug_script/relay-login.sh ' + IP
    //     let bufferStream = '';
    //     let errorStream = '';
    //     var loginPrompt = exec(command, function(error, stdout, stderr) {
    //         if(error) {
    //             console.log('failed to copy ==> '+error)
    //         } 
    //     })
    //     loginPrompt.stdout.on('data', data => {
    //             process.stdout.write(data);
    //             bufferStream += data;
    //         });

    //         loginPrompt.stderr.on('data', error => {
    //             process.stdout.write(error);
    //             errorStream += error;
    //         });
    //         loginPrompt.on('close', code => {
    //             console.log("\n finished");
    //         })
    // }
    else { 
        // console.log(chalk.yellow.bold("Total webSocket is " + wss.clients.size))
        if(wss.clients.size === 0) {
            console.log(chalk.red.bold("NO CLIENT CONNECTED YET")) 
            rl.prompt()
        }  
        var command = line.split(' ')[0]
        var completions = allcommands.split(' ')
        const hits = completions.filter((c) => c.toLowerCase().includes(command));
        if(hits.length < 1){
            cliArgv = line.split(" ")
            switch(cliArgv[0]) {
                case "getRelay":
                    var arrayFound = connectedClinet.filter(function(item) {
                        return item.relayID == cliArgv[1];
                    });
                    if(arrayFound.length > 0) {
                        wss.clients.forEach(function each(client) {
                            client.send(line);
                        });    
                    } else {
                         console.log(chalk.red.bold("NO SUCH RELAY"))
                         rl.prompt()
                    }
                break;

                case "restartMaestro":
                    var arrayFound = connectedClinet.filter(function(item) {
                        return item.relayID == cliArgv[1];
                    });
                    if(arrayFound.length > 0) {
                        wss.clients.forEach(function each(client) {
                            client.send(line);
                        });    
                    } else {
                         console.log(chalk.red.bold("NO SUCH RELAY"))
                         rl.prompt()
                    }
                break;

                case "upgradeGateway":
                    var arrayFound = connectedClinet.filter(function(item) {
                        return (item.relayID == cliArgv[1] || cliArgv[1] === 'all');
                    });
                    if(arrayFound.length > 0) {
                        wss.clients.forEach(function each(client) {
                            client.send(line);
                        });    
                    } else {
                         console.log(chalk.red.bold("NO SUCH RELAY"))
                         rl.prompt()
                    }    
                break;

                case "runCommandOnGW":
                    var arrayFound = connectedClinet.filter(function(item) {
                        return (item.relayID == cliArgv[1] || cliArgv[1] === 'all');
                    });
                    if(arrayFound.length > 0) {
                        wss.clients.forEach(function each(client) {
                            client.send(line);
                        });    
                    } else {
                        console.log(chalk.red.bold("NO SUCH RELAY"))
                        rl.prompt()
                    }    
                break;

                default:
                    wss.clients.forEach(function each(client) {
                        client.send(line);
                    });
                break;
            }

        } else {
            hits.forEach(function(helpWithCompleter) {
                if(help[helpWithCompleter]) {
                    console.log(chalk.blue.bold(helpWithCompleter) ,
                        '\n\t',chalk.bold('Usage:'),
                        '\n\t\t',help[helpWithCompleter].Usage,
                        '\n\t',chalk.bold('Description:'),
                        '\n\t\t',help[helpWithCompleter].Description) 
                }
            })
            rl.prompt()
        }
    }
    // ws.send(line);
}).on('close', () => {
    console.log(chalk.blue.bold('\nHave a great day!'));
    process.exit(0);
});

// app.get('/uri', function (req, res) {
// 	res.status(200).send("command received")
// });

server.listen(port, () => {
  console.log(`Server active on port: ${server.address().port}`);
  rl.prompt()
});
