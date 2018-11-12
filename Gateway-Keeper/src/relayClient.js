const jsonminify = require('jsonminify')
const fs = require('fs')
const WebSocket = require('ws');
var os = require('os')
var exec = require('child_process').exec;

var serverIP = process.argv[2]
var build_version = null

var url = null
//var serverIP = "192.168.0.114"
var uri = "http://"+serverIP+":3232"
console.log(serverIP)

const config = JSON.parse(jsonminify(fs.readFileSync('/wigwag/wwrelay-utils/I2C/relay.conf', 'utf8')));
const ver = JSON.parse(jsonminify(fs.readFileSync('/wigwag/etc/versions.json', 'utf8')));

var ws = null;
delete ver.version
ver.relayID = config.relayID
ver.cloudURL = config.cloudURL
ver.build = ver.packages[0].version
delete ver.packages
//console.log(ver)

var getBaseName = /^[Hh][Tt][Tt][Pp][Ss]?\:\/\/([^\.]+).*/;
var cloudBaseName = getBaseName.exec(ver.cloudURL)[1]

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
	      	ver.IP = iface.address
	      //ws.send(ver)
	      	// ws.send(JSON.stringify(ver,null,4))

	    } else {
	        if(ifname === 'eth0' || ifname == 'wlan0') {
	          // this interface has only one ipv4 adress
	         console.log(ifname, iface.address);
	         ver.IP = iface.address
	      	//ws.send(ver)
	      	//ws.send(JSON.stringify(ver,null,4))
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
					ws.send("openInfo:- "+JSON.stringify(ver,null,4))
				}
				cliArgv = data.split(" ")
				switch(cliArgv[0]) {
					case "getRelay":
						if(cliArgv[1] != ver.relayID) {
							break;
						}
						getIP();
						ws.send(JSON.stringify(ver,null,4))
					break;

					case "getAllRelays":
						getIP();
						ws.send(JSON.stringify(ver,null,4))
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
						if(ver.cloudURL.indexOf('mbed') > -1){
							url = "upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/arm_development/cubietruck/"+build_version+"-field-factoryupdate.tar.gz |& tee upgrade.log &"
						}
						else {
							url = "upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/development/cubietruck/"+build_version+"-field-factoryupdate.tar.gz |& tee upgrade.log &"
						}
						ws.send("Downloading upgrade for " + ver.relayID)
						exec("rm -rf /wigwag/log/devicejs.log", function(error, stdout,stderr) {
							if(error !== null) {
							    console.log(error)
							}
							console.log(stdout)
						    exec(url, function (error, stdout, stderr) {
							    if(error !== null) {
							        console.log(error)
							    }
							    ws.send("Process initiated for relay upgrade for "+ ver.relayID)
							})
						})
					break;

					case "upgradeRelayWithUrl":
						if(!cliArgv[1]){
							ws.send("build_version is not defined")
							break;
						}
						if(cliArgv[2] != ver.relayID) {
							break;
						}
						build_version = cliArgv[1]
						ws.send("Downloading upgrade for " + ver.relayID)
						if(ver.cloudURL.indexOf('mbed') > -1){
							url = "upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/arm_development/cubietruck/"+build_version+"-field-factoryupdate.tar.gz |& tee upgrade.log &"
						}
						else {
							url = "upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/development/cubietruck/"+build_version+"-field-factoryupdate.tar.gz |& tee upgrade.log &"
						}
						ws.send("starting upgrade for " + ver.relayID)
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
							    ws.send("Process initiated for relay upgrade for " + ver.relayID)
							})
						})
					break;

					case "led":
						if(cliArgv[1] != ver.relayID) {
							break;
						}
						exec("led r g b", function (error, stdout, stderr) {
						    if(error !== null) {
						        console.log(error)
						    }
						    console.log(stdout)
						})
						ws.send("Look at the relays")
					break;

					case "restartAllMaestro":
						ws.send("restarting maestro for "+ ver.relayID)
						exec("killall maestro", function (error, stdout, stderr) {
						    if(error !== null) {
						        console.log(error)
						    }
						    console.log(stdout)
						    exec("/etc/init.d/devicejs start", function (error, stdout, stderr) {
							    if(error !== null) {
							        console.log(error)
							    }
							    console.log(stdout)
							    ws.send("Look at the relay.")
							})
						})
					break;

					case "restartMaestro":
						if(cliArgv[1] != ver.relayID) {
							break;
						}
						ws.send("restarting maestro for "+ ver.relayID)
						exec("killall maestro", function (error, stdout, stderr) {
						    if(error !== null) {
						        console.log(error)
						    }
						    console.log(stdout)
						    exec("/etc/init.d/devicejs start", function (error, stdout, stderr) {
							    if(error !== null) {
							        console.log(error)
							    }
							    console.log(stdout)
							    ws.send("Look at the relay.")
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
						    var status = "send upgrade status for "+ ver.relayID + '...\n' + stdout +'\n ============================================================='
							ws.send(status)
						})
					}catch (err) {
						ws.send("Failed " + err)
					}
					break;

					case "getUpgrade":
						if(cliArgv[1] != ver.relayID) {
							break;
						}
						try {
							ws.send("send upgrade status for "+ ver.relayID)
							exec('cat upgrade.log', function(error, stdout, stderr) {
								if(error !== null) {
							        console.log(error)
							    }
							    console.log(stdout)
								var status = "send upgrade status for "+ ver.relayID + '...\n' + stdout +'\n ============================================================='
								ws.send(status)
							})
						}catch (err) {
							ws.send("Failed " + err)
						}
					break;

					case "killAllUpgrade":
						exec("killall upgrade", function(error, stdout, stderr) {
							if(error !== null) {
						        ws.send("error in kill process for "+ ver.relayID)
						    }
						    ws.send("upgrade process killed for "+ver.relayID)
						    exec("rm -rf /upgrades/f.tar.gz", function(error, stdout, stderr) {
								if(error !== null) {
							        ws.send("error in removing f.tar.gz")
							    }
							    ws.send("f.tar.gz removed for "+ ver.relayID)
							})
						})
					break;

					case "killUpgrade":
						if(cliArgv[1] != ver.relayID) {
							break;
						}
						exec("killall upgrade", function(error, stdout, stderr) {
							if(error !== null) {
						        ws.send("error in kill process for "+ ver.relayID)
						    }
						    ws.send("upgrade process killed for "+ ver.relayID)
						    exec("rm -rf /upgrades/*", function(error, stdout, stderr) {
								if(error !== null) {
							        ws.send("error in removing f.tar.gz for "+ ver.relayID)
							    }
							    ws.send("f.tar.gz removed for "+ ver.relayID)
							})
						})
					break;

					case "upgradeGateway":
						if((cliArgv[1] == ver.relayID  || cliArgv[1] == 'all') && (cliArgv[2] == cloudBaseName || cliArgv[2] == 'all')) {
							var msg = ''
							if(cloudBaseName == 'gateways-wigwag-int') {
								msg = "ARMSCPIP " + ver.IP	+ " "+ cliArgv[3]
							} else {
								msg = "WWSCPIP " + ver.IP + " " + cliArgv[3]
							}

							ws.send(msg)
						}
					break;

					case "runCommandOnGW":
						if((cliArgv[1] == ver.relayID  || cliArgv[1] == 'all')) {
							cliArgv.shift()  // skip node.exe
							cliArgv.shift()  // skip name of js file

							command = cliArgv.join(" ")
							exec(command, function(error, stdout, stderr) {
								if(error !== null) {
							        ws.send("Error in running for " + ver.relayID + ".\n " + error)
							    } else{
							    	ws.send("Command ran succesfully for " + ver.relayID + ".\n "+ stdout)
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
			ws.send("closeInfo:- "+JSON.stringify(ver,null,4))
			console.log("Events websocket disconnected " + data);
			connected = false;
		}
		)
		ws.removeEventListener('error');
		ws.on('error', function incoming(error) {
			ws.send("closeInfo:- "+JSON.stringify(ver,null,4))
			console.log(error);
			connected = false;
		});

		process.on('SIGINT', function() {
			ws.send("closeInfo:- "+JSON.stringify(ver,null,4))
			process.exit()	
		})
		// ws.on('error', function incoming(error) { console.log(error);
		//     ws.close('message',function incoming(data){ console.log(data);})
		// });
	// }, 7000);
}

setInterval(function() {
	if(!connected && !inProgress) {
		inProgress = true;
		tryToConnect();
	}
}, 10000);

tryToConnect();
// ws = new WebSocket(uri)