var http = require("http")
var express = require('express');
const WebSocket = require('ws');
const uuid = require("uuid");
const readline = require('readline');
const fs = require('fs')



var allcommands = 'getRelay getAllRelays upgradeAllRelays upgradeRelay led restartAllMaestro restartMaestro getAllUpgrade getUpgrade killAllUpgrade killUpgrade '

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
const port = 3000
process.setMaxListeners(0)
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

wss.on('connection', function connection(ws,req) {
    ws.id = uuid.v4();
    ws.send(ws.id+"");

    rl.prompt()
    rl.on('line', (line) => {
        ws.send(line)
    }).on('close', () => {
        console.log('Have a great day!');
        process.exit(0);
    });
    ws.on('message', function incoming(data) {
        console.log(data)
    })
});

// app.get('/uri', function (req, res) {
// 	res.status(200).send("command received")
// });

server.listen(port, () => {
  console.log(`Server active on port: ${server.address().port}`);
});
