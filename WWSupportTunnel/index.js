var path = require('path');
var exec = require('child_process').exec;
var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);

var randomPort = -1; // choose a random port on the support sever
var minPort = 19991; // smallest port number the client can reverse tunnel using
var maxPort = 19999; // biggest port number the client can reverse tunnel using
var port = 3000; // port of the current program
var supportIP = '198.58.101.57'; // ip address of the server
var currentIP = '0.0.0.0';

function randomInt(low, high){
	return Math.floor(Math.random() * (high - low)) + low;
}

function getSelfIPAddr(){
	var command = "ifconfig | grep eth0 -A 1 | awk '{ print $2 }' | grep addr:";
	var getSelfIP = exec(command, function(error, stdout, stderr){
		currentIP = stdout.split(':')[1];
		console.log(currentIP);
		if (currentIP === undefined){
			var command = "ifconfig | grep wlan0 -A 1 | awk '{ print $2 }' | grep addr:";
			var getSelfIP = exec(command, function(error, stdout, stderr){
				currentIP = stdout.split(':')[1];
				console.log(currentIP);
			});
		}
	});
}

function startTunnel(){
	console.log('startTunnel');
	randomPort = randomInt(minPort, maxPort);

	// var command = 'ssh -p 3232 -f -N -R ' + randomPort + ':localhost:22 support@' + supportIP + ' -i /home/joe/.ssh/relay_support_key';
	var command = 'ssh -f -N -R ' + randomPort + ':localhost:22 support@' + supportIP + ' -i relay_support_key';
	var sshSupport = exec(command, function(error, stdout, stderr){
		console.log("Started Support Tunnel");
	});
}

function killTunnel(){
	// get the PIDs of every process associated with tunneling
	// var command = "ps ax | grep 'ssh -p 3232 -f -N -R' | awk '{ print $5" + '" "' + "$1 }'"
	var command = "ps ax | grep 'ssh -f -N -R' | awk '{ print $5" + '" "' + "$1 }'"
	var getPIDs = exec(command, function(error, stdout, stderr){
		// get the tuple of {command, pid}
		var pidCommands = stdout.split('\n')
		for (var i=0; i < pidCommands.length; i++){
			var pair = pidCommands[i];
			var thing = pair.split(' ');
			if (thing[0] === 'ssh'){
				command = 'kill ' + thing[1];
				var killTun = exec(command, function(error, stdout, stderr){
					console.log(command + " - killed tunnel");
					killingTunnel = false;
				});
			}
		}
	});
	console.log('Killed All Tunnels');
}

function generateKey(){
	console.log('generate key');
	// create .ssh directory for support, ignore error if already exists    
	var command = 'mkdir /home/support/.ssh';   
	var mkdirSSH = exec(command, function(error, stdout, stderr){
		// remove all files (private key, public key, "public/" folder) that already may be there             
		command = 'rm -rf /home/support/.ssh/id_rsa* && rm -rf /home/support/.ssh/authorized_keys'; 
		var removeSSH = exec(command, function(error, stdout, stderr){
			// generate private and public keys for support
			command = 'ssh-keygen -t rsa -N "" -f /home/support/.ssh/id_rsa';         
			var genSSH = exec(command, function(error, stdout, stderr){ 
				// create "public/" folder for exposure to user
				command = 'cp /home/support/.ssh/id_rsa public';         
				var cpPrivate = exec(command, function(error, stdout, stderr){ 
					// add public key to authorized_keys files       
					command = 'cat /home/support/.ssh/id_rsa.pub >> /home/support/.ssh/authorized_keys';             
					var authSSH = exec(command, function(error, stdout, stderr){
						console.log('finished generating keys');
					});
				});
			});
		});
	});
}
function rejectedPromise(callingFunction){
	console.log('promise rejected: ' + callingFunction);
}

function removeKeys(){
	var command = 'rm -rf /home/support/.ssh/id_rsa*  && rm -rf /home/support/.ssh/authorized_keys && rm public/id_rsa';
	var removeSSH = exec(command, function(error, stdout, stderr){
		console.log('removed keys');
	});
}

function getStart(){
	// both of these functions happen asynchronously, but that's okay. They do not depend on each other
	startTunnel(); 	// start tunnel to cloud support
	generateKey();	// generate keys to client-relay, so server-support can tunnel to relay
}

function getStop(){
	console.log('stopping tunnel');
	randomPort = -1;

	killTunnel();
	removeKeys();
}

function mainBody(){
	getStop();
    getSelfIPAddr();

	app.get('/', function (req, res) {
		req.socket.on("error", function(){});
		res.socket.on("error", function(){});
		res.redirect('index.html');
	});

	app.get('/returnPort', function(req, res){
		res.status(200).send("" + randomPort);
	});

	app.get('/returnKey', function(req, res){
		var command = 'cat /home/support/.ssh/id_rsa';
		var displaySSH = exec(command, function(error, stdout, stderr){
			res.status(200).send(stdout);
		});
	});

	app.get('/start', function(req, res){
		getStart();
		res.status(200).send();
	});

	app.get('/stop', function(req, res){
		getStop();
		res.status(200).send();
	});

	app.get('/downloadKey', function(req, res){
		var file = path.join(__dirname, "/public/id_rsa");
		res.download(file);
	});

    // serve static files out of ./public as well
    app.use(express.static(path.join(__dirname,'public')));

    io.on('connection', function(socket){
    	console.log("someone connected");
    	socket.on('disconnect', function(){
	    	console.log('stopping tunnel');
    		console.log('user disconnected');
			randomPort = -1;
			killTunnel();
			removeKeys();  		
		});
    });


	http.listen(port, function(){
		console.log('supportTunnel listening on ' + currentIP + ':' + port);
	});

}

mainBody();
