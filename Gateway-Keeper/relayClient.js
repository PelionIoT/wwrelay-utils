const jsonminify = require('jsonminify')
const fs = require('fs')
const WebSocket = require('ws');
var exec = require('child_process').exec;

// var serverIP = process.argv[2]
var exec = require('child_process').exec;
var serverIP = "192.168.0.114"
var uri = "http://"+serverIP+":3000"

const config = JSON.parse(jsonminify(fs.readFileSync('/wigwag/wwrelay-utils/I2C/relay.conf', 'utf8')));
const ver = JSON.parse(jsonminify(fs.readFileSync('/wigwag/etc/versions.json', 'utf8')));


delete ver.version
ver.relayID = config.relayID
ver.cloudURL = config.cloudURL
ver.build = ver.packages[0].version
delete ver.packages
// console.log(config.relayID)
// console.log(config.cloudURL)
//console.log(ver.packages[0].version)
console.log(ver)


ws = new WebSocket(uri)


ws.on('open',function open(){
	console.log("opened")
	ws.on('message', function incoming(data) {
		if(data.indexOf("relayInfo") > -1 && data.indexOf(ver.relayID) > -1) {
			ws.send(JSON.stringify(ver))
		}

		if(data.indexOf("relayInfo") > -1 && data.indexOf('all') > -1) {
			ws.send(JSON.stringify(ver))
		}

		if(data.indexOf("upgrade") > -1 && data.indexOf('all') > -1) {
			ws.send("starting upgrade for " + ver.relayID)
			ws.send(JSON.stringify("starting upgrade"))
			exec("rm -rf /wigwag/log/devicejs.log", function(error, stdout,stderr) {
				if(error !== null) {
				    console.log(error)
				}
				console.log(stdout)
				// exec("killall maestro", function (error, stdout, stderr) {
				//     if(error !== null) {
				//         console.log(error)
				//     }
				//     console.log(stdout)
				//     exec("/etc/init.d/devicejs start", function (error, stdout, stderr) {
				// 	    if(error !== null) {
				// 	        console.log(error)
				// 	    }
				// 	    console.log(stdout)
				// 	    exec("udhcpc", function (error, stdout, stderr) {
				// 		    if(error !== null) {
				// 		        console.log(error)
				// 		    }
				// 		    console.log(stdout)
						    exec("upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/development/cubietruck/102.0.357-field-factoryupdate.tar.gz |& tee upgrade.log &", function (error, stdout, stderr) {
							    if(error !== null) {
							        console.log(error)
							    }
							    ws.send("Process initiated for relay upgrade.")
							})
				// 		})
				// 	})
				// })
			})
		}

		if(data.indexOf("upgrade") > -1 && data.indexOf(ver.relayID) > -1) {
			ws.send(JSON.stringify("starting upgrade"))
			exec("rm -rf /wigwag/log/devicejs.log", function(error, stdout,stderr) {
				if(error !== null) {
				    console.log(error)
				}
				console.log(stdout)
				// exec("killall maestro", function (error, stdout, stderr) {
				//     if(error !== null) {
				//         console.log(error)
				//     }
				//     console.log(stdout)
				//     exec("/etc/init.d/devicejs start", function (error, stdout, stderr) {
				// 	    if(error !== null) {
				// 	        console.log(error)
				// 	    }
				// 	    console.log(stdout)
				// 	    exec("udhcpc", function (error, stdout, stderr) {
				// 		    if(error !== null) {
				// 		        console.log(error)
				// 		    }
				// 		    console.log(stdout)
						    exec("upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/development/cubietruck/102.0.357-field-factoryupdate.tar.gz |& tee upgrade.log &", function (error, stdout, stderr) {
							    if(error !== null) {
							        console.log(error)
							    }
							    console.log(stdout)
							    ws.send("Process initiated for relay upgrade.")
							})
				// 		})
				// 	})
				// })
			})
			
		}
		if(data.indexOf("led") > -1 && data.indexOf(ver.relayID) > -1) {
			exec("led r g b", function (error, stdout, stderr) {
			    if(error !== null) {
			        console.log(error)
			    }
			    console.log(stdout)
			})
			ws.send("Look at the relay.")
		}

		if(data.indexOf("restart") > -1 && data.indexOf('all') > -1) {
			ws.send("Ok")
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

		if(data.indexOf("restart") > -1 && data.indexOf(ver.relayID) > -1) {
			ws.send("Ok")
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

		if(data.indexOf("read") > -1 && data.indexOf(ver.relayID) > -1) {
			try {
				exec('cat upgrade.log', function(error, stdout, stderr) {
					if(error !== null) {
				        console.log(error)
				    }
				    console.log(stdout)
					ws.send(stdout)
				})
				// var data = fs.readFileSync('/home/root/upgrade.log','utf8')
				// ws.send(data)
			}catch (err) {
				ws.send("Failed " + err)
			}
			
		}
		//console.log("message: " + data)
		//console.log(relayConf)
	})
	ws.on('close',function close(data){console.log("Events websocket disconnected " + data);})
    ws.on('error', function incoming(error) { console.log(error);});
})
ws.on('error', function incoming(error) { console.log(error);
    ws.close('message',function incoming(data){ console.log(data);})
});



