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


var allcommands = 'getRelay getAllRelays upgradeAllRelays upgradeRelay led restartAllMaestro restartMaestro getAllUpgrade getUpgrade killAllUpgrade killUpgrade copyBuildAndUpgrade '

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
        if(data.indexOf('SCPIP') > -1) {
            //console.log('copy bild to IP '+ data)
            IP = data.split(' ')[1]
            cmd = "./debug_script/expect-ssh-copy.sh " + IP
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
    } else { 
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
