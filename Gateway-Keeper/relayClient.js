const jsonminify = require('jsonminify')
const fs = require('fs')
const WebSocket = require('ws');
var os = require('os')
var exec = require('child_process').exec;

var serverIP = process.argv[2]
var build_version = process.argv[3]
var exec = require('child_process').exec;

const armUpgarde_url = "upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/arm_development/cubietruck/"+build_version+"-field-factoryupdate.tar.gz |& tee upgrade.log &"
const wigwagUgrade_url = "upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/development/cubietruck/"+build_version+"-field-factoryupdate.tar.gz |& tee upgrade.log &"
//var serverIP = "192.168.0.114"
var uri = "http://"+serverIP+":3000"
console.log(serverIP)

const config = JSON.parse(jsonminify(fs.readFileSync('/wigwag/wwrelay-utils/I2C/relay.conf', 'utf8')));
const ver = JSON.parse(jsonminify(fs.readFileSync('/wigwag/etc/versions.json', 'utf8')));


delete ver.version
ver.relayID = config.relayID
ver.cloudURL = config.cloudURL
ver.build = ver.packages[0].version
delete ver.packages
console.log(ver)


ws = new WebSocket(uri)

ws.on('open',function open(){
	console.log("opened")
	ws.on('message', function incoming(data) {

		if(data.indexOf("getRelay") > -1 && data.indexOf(ver.relayID) > -1) {
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
		          ws.send(JSON.stringify(ver,null,4))

		        } else {
		            if(ifname === 'eth0' || ifname == 'wlan0') {
		              // this interface has only one ipv4 adress
		             console.log(ifname, iface.address);
		             ver.IP = iface.address
		          	//ws.send(ver)
		          	ws.send(JSON.stringify(ver,null,4))
		             addr =  iface.address;
		          }
		        }
		        ++alias;
		      });
		    });
		}

		else if(data.indexOf("getAllRelays") > -1) {
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
		          ws.send(JSON.stringify(ver,null,4))

		        } else {
		            if(ifname === 'eth0' || ifname == 'wlan0') {
		              // this interface has only one ipv4 adress
		             console.log(ifname, iface.address);
		             ver.IP = iface.address
		          	//ws.send(ver)
		          	ws.send(JSON.stringify(ver,null,4))
		             addr =  iface.address;
		          }
		        }
		        ++alias;
		      });
		    });
		}

		else if(data.indexOf("upgradeAllRelays") > -1) {
			ws.send("starting upgrade for " + ver.relayID)
			//ws.send(JSON.stringify("starting upgrade"))
			exec("rm -rf /wigwag/log/devicejs.log", function(error, stdout,stderr) {
				if(error !== null) {
				    console.log(error)
				}
				console.log(stdout)
				if(ver.cloudURL.indexOf('mbed') > -1){
					url = armUpgarde_url
				}
				else {
					url = wigwagUgrade_url
				}
			    exec(url, function (error, stdout, stderr) {
				    if(error !== null) {
				        console.log(error)
				    }
				    ws.send("Process initiated for relay upgrade.")
				})
			})
		}

		else if(data.indexOf("upgradeRelay") > -1 && data.indexOf(ver.relayID) > -1) {
			ws.send("starting upgrade for " + ver.relayID)
			//ws.send(JSON.stringify("starting upgrade"))
			exec("rm -rf /wigwag/log/devicejs.log", function(error, stdout,stderr) {
				if(error !== null) {
				    console.log(error)
				}
				console.log(stdout)
				if(ver.cloudURL.indexOf('mbed') > -1){
					url = armUpgarde_url
				}
				else {
					url = wigwagUgrade_url
				}
			    exec(url, function (error, stdout, stderr) {
				    if(error !== null) {
				        console.log(error)
				    }
				    console.log(stdout)
				    ws.send("Process initiated for relay upgrade.")
				})
			})			
		}

		else if(data.indexOf("led") > -1 && data.indexOf(ver.relayID) > -1) {
			exec("led r g b", function (error, stdout, stderr) {
			    if(error !== null) {
			        console.log(error)
			    }
			    console.log(stdout)
			})
			ws.send("Look at the relays")
		}

		else if(data.indexOf("restartAllMaestro") > -1 && data.indexOf('all') > -1) {
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
		}

		else if(data.indexOf("restartMaestro") > -1 && data.indexOf(ver.relayID) > -1) {
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
		}

		else if(data.indexOf("getAllUpgrade") > -1) {
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
			
		}

		else if(data.indexOf("getUpgrade") > -1 && data.indexOf(ver.relayID) > -1) {
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
		}

		else if(data.indexOf("killAllUpgrade") > -1) {
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
		}

		else if(data.indexOf("killUpgrade") > -1 && data.indexOf(ver.relayID)) {
			exec("killall upgrade", function(error, stdout, stderr) {
				if(error !== null) {
			        ws.send("error in kill process for "+ ver.relayID)
			    }
			    ws.send("upgrade process killed for "+ ver.relayID)
			    exec("rm -rf /upgrades/f.tar.gz", function(error, stdout, stderr) {
					if(error !== null) {
				        ws.send("error in removing f.tar.gz for "+ ver.relayID)
				    }
				    ws.send("f.tar.gz removed for "+ ver.relayID)				    
				})	
			})
		}

		else {

		}

	})
	ws.on('close',function close(data){console.log("Events websocket disconnected " + data);})
    ws.on('error', function incoming(error) { console.log(error);});
})
ws.on('error', function incoming(error) { console.log(error);
    ws.close('message',function incoming(data){ console.log(data);})
});