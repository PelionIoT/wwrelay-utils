var http = require("http")
var express = require('express');
const WebSocket = require('ws');
const uuid = require("uuid");
const readline = require('readline');
const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout,
	prompt: 'WS> '
});

var app = express();
const port = 3000



const server = http.createServer(app);
const wss = new WebSocket.Server({ server });
wss.on('connection', function connection(ws,req) {

  	ws.id = uuid.v4();
  	ws.send(ws.id+"");
 
  	rl.prompt()
  	rl.on('line', (line) => {
  	if(line.indexOf('relayInfo') > -1 ) {
  		ws.send(line)
  	}

  	if(line.indexOf('upgrade') > -1 ) {
  		ws.send(line)
  	}

  	if(line.indexOf('led') > -1 ) {
  		ws.send(line)
  	}

    if(line.indexOf('restart') > -1 ) {
      ws.send(line)
    }

    if(line.indexOf('read') > -1 ) {
      ws.send(line)
    }

	}).on('close', () => {
	  console.log('Have a great day!');
	  process.exit(0);
	});
	ws.on('message', function incoming(data) {
	    console.log(data)
	})
});

app.get('/uri', function (req, res) {
	res.status(200).send("command received")
});

server.listen(port, () => {
    console.log(`Server active on port: ${server.address().port}`);
});
