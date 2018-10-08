const http = require("http")
const express = require('express');
const WebSocket = require('ws');
const uuid = require("uuid");
const readline = require('readline');
const fs = require('fs')
const util = require('util')
const program = require('commander');
var exec = require('child_process').exec;
var spawn = require('child_process').spawn;
var help = require('./utils/helpCommand');
var chalk = require('chalk')

var version = "1.0.0"

program
    .version(version)
    .usage('[options] command {args...}')
    .option('-b, --build [build number for download]', 'download a build for scp to all the relays')
    .parse(process.argv);


// if(program.build){
//     var child = spawn('wget', ['-c', '-O', __dirname + "/build/" + program.build +"-field-factoryupdate.tar.gz" ,"https://code.wigwag.com/ugs/builds/development/cubietruck/"+program.build+"-field-factoryupdate.tar.gz"]);
//     // cmd = "sudo wget -O "+__dirname+"/build/"+program.build+"-field-factoryupdate.tar.gz https://code.wigwag.com/ugs/builds/development/cubietruck/"+program.build+"-field-factoryupdate.tar.gz --no-check-certificate"
//     // console.log(cmd)
//     // exec(cmd, function(error, stdout, stderr) {
//     //     if (error !== null) {
//     //         console.error('Failed ', error);
//     //     }
//     //     console.log(stdout)
//     // });
// }


var allcommands = 'getRelay getAllRelays upgradeAllRelays upgradeRelay led restartAllMaestro restartMaestro getAllUpgrade getUpgrade killAllUpgrade killUpgrade copyBuildAndUpgrade downloadBuild clearBuild '

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
    ws.send(ws.id+"");
    ws.on('message', function incoming(data) {
        //console.log(data)
        if(data.indexOf('SCPIP') > -1) {
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
                console.log(stdout)
            })
        } else {
            console.log(data)
        }
    })
});

rl.prompt()
rl.on('line', (line) => {
    if(line.indexOf('-h') > -1) {
        var command = line.split(' ')[0]
        if(help[command]) {
            console.log(chalk.blue.bold(command) ,
                        '\n\t',chalk.bold('Usage:'),
                        '\n\t\t',help[command].Usage,
                        '\n\t',chalk.bold('Description:'),
                        '\n\t\t',help[command].Description) 
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
                console.log('failed to copy ==> '+error)
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
                process.stdout.write("[ Downloading Build "+ data + ' ]');
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
                process.stdout.write("[ Downloading Build "+ error + ' ]');
                //printProgress(status[0], size[0], eta[0], "102.0.380-field-factoryupdate.tar.gz")
                errorStream += error;
            });
            child.on('close', code => {
                console.log("\nDownloading finished");
            })
    } else if(line.indexOf('clearBuild') > -1) {
        var command = "rm -rf "+__dirname+"/build/*"
        exec(command,function(error, stdout, stderr) {
            if(error) {
                console.log('failed to remove'+error)
            }
            console.log("Build folder is clean.")
        })
    }else { 
        wss.clients.forEach(function each(client) {
            client.send(line);
        });
    }
    // ws.send(line);
}).on('close', () => {
    console.log('Have a great day!');
    process.exit(0);
});

// app.get('/uri', function (req, res) {
// 	res.status(200).send("command received")
// });

server.listen(port, () => {
  console.log(`Server active on port: ${server.address().port}`);
});
