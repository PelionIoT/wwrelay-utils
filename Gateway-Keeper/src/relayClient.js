const jsonminify = require('jsonminify')
const fs = require('fs')
const WebSocket = require('ws');
var os = require('os')
var exec = require('child_process').exec;

var serverIP = process.argv[2]
var build_version = null
var getBaseName = /^[Hh][Tt][Tt][Pp][Ss]?\:\/\/([^\.]+).*/;

var url = null
var relayInfo = {}
//var serverIP = "192.168.0.114"
var uri = "http://"+serverIP+":3232"
console.log(serverIP)

try{
	const config = JSON.parse(jsonminify(fs.readFileSync('/wigwag/wwrelay-utils/I2C/relay.conf', 'utf8')));
	const ver = JSON.parse(jsonminify(fs.readFileSync('/wigwag/etc/versions.json', 'utf8')));
	var ws = null;
	delete ver.version
	relayInfo.relayID = config.relayID
	relayInfo.cloudURL = config.cloudURL
	relayInfo.build = ver.packages[0].version
	delete ver.packages
	var cloudBaseName = getBaseName.exec(relayInfo.cloudURL)[1]
	//console.log(ver)
} catch(err) {
	relayInfo.relayID = "unknownID"
	relayInfo.cloudURL = "https://unknown.wigwag.io"
	relayInfo.build = "0.0.0"
	var cloudBaseName = getBaseName.exec(relayInfo.cloudURL)[1]
}


//var cloudBaseName = getBaseName.exec(relayInfo.cloudURL)[1]

var killCommand = "kill $(ps aux | grep 'relayClient' | grep -v " + process.pid +" | awk '{print $2}')"
exec(killCommand, function(error, stdout,stderr) {
	if(error !== null) {
	    console.log(error);
	}
	console.log(stdout);
});

function getIP() {
	var ifaces = os.networkInterfaces();
	var addr;
	Object.keys(ifaces).forEach(function (ifname) {
	  	var alias = 0;

	  	ifaces[ifname].forEach(function (iface) {
	    if ('IPv4' !== iface.family || iface.internal !== false) {
	      // skip over internal (i.e. 127.0.0.1) and non-ipv4 addresses
	      return;
	    }

	    if (alias >= 1) {
	      // this single interface has multiple ipv4 addresses
	      	console.log(ifname + ':' + alias, iface.address);
	      	relayInfo.IP = iface.address
	      //ws.send(ver)
	      	// ws.send(JSON.stringify(relayInfo,null,4))

	    } else {
	        if(ifname === 'eth0' || ifname == 'wlan0') {
	          // this interface has only one ipv4 adress
	         console.log(ifname, iface.address);
	         relayInfo.IP = iface.address
	      	//ws.send(relayInfo)
	      	//ws.send(JSON.stringify(relayInfo,null,4))
	         addr =  iface.address;
	      }
	    }
	    ++alias;
	  });
	});
}
getIP();

var connected = false;
var inProgress = false;

function tryToConnect() {
	// setTimeout(function() {
    if(ws !== null) {
        ws.close();
        delete ws;
    }
	ws = new WebSocket(uri);
	ws.removeEventListener('open');
	ws.on('open',function open(){
		connected = true;
		inProgress = false;
		console.log("opened");
		ws.removeEventListener('message');
		ws.on('message', function incoming(data) {
			if(data.indexOf('_id') > -1) {
				relayInfo.clientID = data.split("_")[0]
				ws.send("openInfo:- "+JSON.stringify(relayInfo,null,4))
			}
			cliArgv = data.split(" ")
			switch(cliArgv[0]) {
				case "getRelay":
					if(cliArgv[1] != relayInfo.relayID) {
						break;
					}
					getIP();
					ws.send(JSON.stringify(relayInfo,null,4))
				break;

				case "getAllRelays":
					getIP();
					ws.send(JSON.stringify(relayInfo,null,4))
				break;

				case "upgradeAllRelaysWithUrl":

					if(!cliArgv[1]){
						ws.send("Build_version is not defined")
						break;
					}
					if(cliArgv[2] != cloudBaseName || cliArgv[2] != 'all') {
						break;
					}
					build_version = cliArgv[1]
					if(relayInfo.cloudURL.indexOf('mbed') > -1){
						url = "upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/arm_development/cubietruck/"+build_version+"-field-factoryupdate.tar.gz |& tee upgrade.log &"
					}
					else {
						url = "upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/development/cubietruck/"+build_version+"-field-factoryupdate.tar.gz |& tee upgrade.log &"
					}
					ws.send("Downloading upgrade for " + relayInfo.relayID)
					exec("rm -rf /wigwag/log/devicejs.log", function(error, stdout,stderr) {
						if(error !== null) {
						    console.log(error)
						}
						console.log(stdout)
					    exec(url, function (error, stdout, stderr) {
						    if(error !== null) {
						        console.log(error)
						    }
						    ws.send("Process initiated for relay upgrade for "+ relayInfo.relayID)
						})
					})
				break;

				case "upgradeRelayWithUrl":
					if(!cliArgv[1]){
						ws.send("build_version is not defined")
						break;
					}
					if(cliArgv[2] != relayInfo.relayID) {
						break;
					}
					build_version = cliArgv[1]
					ws.send("Downloading upgrade for " + relayInfo.relayID)
					if(relayInfo.cloudURL.indexOf('mbed') > -1){
						url = "upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/arm_development/cubietruck/"+build_version+"-field-factoryupdate.tar.gz |& tee upgrade.log &"
					}
					else {
						url = "upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/development/cubietruck/"+build_version+"-field-factoryupdate.tar.gz |& tee upgrade.log &"
					}
					ws.send("starting upgrade for " + relayInfo.relayID)
					//ws.send(JSON.stringify("starting upgrade"))
					exec("rm -rf /wigwag/log/devicejs.log", function(error, stdout,stderr) {
						if(error !== null) {
						    console.log(error)
						}
						console.log(stdout)
					    exec(url, function (error, stdout, stderr) {
						    if(error !== null) {
						        console.log(error)
						    }
						    console.log(stdout)
						    ws.send("Process initiated for relay upgrade for " + relayInfo.relayID)
						})
					})
				break;

				case "getAllUpgrade":
					try {
						exec('cat upgrade.log', function(error, stdout, stderr) {
						if(error !== null) {
					        console.log(error)
					    }
					    console.log(stdout)
					    var status = "send upgrade status for "+ relayInfo.relayID + '...\n' + stdout +'\n ============================================================='
						ws.send(status)
					})
				}catch (err) {
					ws.send("Failed " + err)
				}
				break;

				case "getUpgrade":
					if(cliArgv[1] != relayInfo.relayID) {
						break;
					}
					try {
						ws.send("send upgrade status for "+ relayInfo.relayID)
						exec('cat upgrade.log', function(error, stdout, stderr) {
							if(error !== null) {
						        console.log(error)
						    }
						    console.log(stdout)
							var status = "send upgrade status for "+ relayInfo.relayID + '...\n' + stdout +'\n ============================================================='
							ws.send(status)
						})
					}catch (err) {
						ws.send("Failed " + err)
					}
				break;

				case "upgradeGateway":
					if((cliArgv[1] == relayInfo.relayID  || cliArgv[1] == 'all') && (cliArgv[2] == cloudBaseName || cliArgv[2] == 'all')) {
						var msg = ''
						//if(cloudBaseName == 'gateways-wigwag-int') {
						if(relayInfo.cloudURL.indexOf('mbed') > -1) {
							msg = "ARMSCPIP " + relayInfo.IP	+ " "+ cliArgv[3]
						} else {
							msg = "WWSCPIP " + relayInfo.IP + " " + cliArgv[3]
						}

						ws.send(msg)
					}
				break;

				case "runCommandOnGW":
					if((cliArgv[1] == relayInfo.relayID  || cliArgv[1] == 'all')) {
						cliArgv.shift()  // skip node.exe
						cliArgv.shift()  // skip name of js file

						command = cliArgv.join(" ")
						exec(command, function(error, stdout, stderr) {
							if(error !== null) {
						        ws.send("Error in running for " + relayInfo.relayID + ".\n " + error)
						    } else{
						    	ws.send("Command ran succesfully for " + relayInfo.relayID + ".\n "+ stdout)
							}
						})
					}
					
				break;

				default:
					//ws.send("Unknown Command")
				break;
			}
		})
	})

	ws.removeEventListener('close');
	ws.on('close',function close(data) {
		//ws.send("closeInfo:- "+JSON.stringify(ver,null,4))
		console.log("Events websocket disconnected " + data);
		connected = false;
		inProgress = false;
	}
	)
	ws.removeEventListener('error');
	ws.on('error', function incoming(error) {
		//ws.send("closeInfo:- "+JSON.stringify(ver,null,4))
		console.log(error);
		connected = false;
		inProgress = false;
	});

	process.on('SIGINT', function() {
		ws.send("closeInfo:- "+JSON.stringify(relayInfo,null,4))
		process.exit()	
	})
}

setInterval(function() {
	if(!connected && !inProgress) {
		inProgress = true;
		tryToConnect();
	}
}, 10000);

// tryToConnect();
// ws = new WebSocket(uri)
