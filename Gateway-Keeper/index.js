var http = require("http")
var express = require('express');
const WebSocket = require('ws');
const uuid = require("uuid");
const readline = require('readline');


const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: 'GK> '
})

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
