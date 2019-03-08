'use strict';

const fs = require('fs');
const exec = require('child_process').exec;
const execSync = require('child_process').execSync;
const jsonminify = require('jsonminify');
const path = require('path');
const program = require('commander');
const _ = require('underscore');
const mkdirp = require('mkdirp');
const util = require('util');

program
	.version('2.0.1')
    .option('-d, --debug', 'Turns on debug output')
	.option('<gw_identity_json_file>', 'New edge gateway identity JSON formatted file')
	// .option('-e, --erase', 'Erase the eeprom')
	// .option('-s, --skipeeprom', 'skip the eeprom portion')
	// .option('-S, --skipSSL', 'skip the ssl portion')
	// .option('-v, --verify', 'verify eeprom write')
	.parse(process.argv);

program.on('--help', () => {
	console.log(' Examples:');
	console.log("");
	console.log("  $ node writeEEPROM.js <identity.json>");
});

const softEepromDirPath = "/userdata/edge_gw_config"
const softEepromFile = "identity.json"
const softEepromOriginalFile = "identity_original.json"

var logerr = function() {
    if (arguments[0]) arguments[0] = "ERR>> " + arguments[0];
    console.error(util.format.apply(util, arguments));
}

var loginfo = function() {
    console.log(util.format.apply(util, arguments));
}
var logdbg = function() {
    if (program.debug) {
        if (arguments[0]) arguments[0] = "dbg>> " + arguments[0];
        console.log(util.format.apply(util, arguments));
    }
}

//Save edge-gateway-identity on FS
class softEepromHandler {
	constructor() {
		this._eepromDirPath = softEepromDirPath;
		this._eepromFilePath = path.join(this._eepromDirPath, softEepromFile);
		this._orgEepromFilePath = path.join(this._eepromDirPath, softEepromOriginalFile);

		logdbg('Original identity location - ', this._orgEepromFilePath);
		logdbg('Identity location ', this._eepromFilePath);
	}

	init_eeprom() {
		var self = this;
		return new Promise(function(resolve, reject) {
			mkdirp(self._eepromDirPath, function(err) {
				if(err) {
					logerr('Failed to create ' + self._eepromDirPath + ' error- ', err);
					reject(err);
					return;
				}
				logdbg('Successfully created edge gateway configuration directory!');
				resolve();
			})
		})
	}

	main_erase() {
		execSync('rm ' + this._eepromFilePath);
		execSync('rm ' + this._orgEepromFilePath);
	}

	cleanup() {
		execSync('rm -rf ./pal');
		execSync('rm -rf ./mcc_config*');
	}

	install_eeprom(obj) {
		var self = this;
		var ee = obj.ee;
		function write_new_identity() {
			return new Promise((resolve, reject) => {
				logdbg("In install EEPROM function");
				process.stdout.write("Writing...");
				let interval = setInterval(() => {
					process.stdout.write(".");
				}, 500);
				try {
					fs.writeFile(self._orgEepromFilePath, JSON.stringify(ee, null, 4), 'utf8', (err) => {
						if(err) {
							logerr("Write failed " + err);
							clearInterval(interval);
							reject(err);
						} else {
							clearInterval(interval);
							loginfo('Wrote successfully!');
							// This is done to make sure the gateway recovers if the file is not flushed to the disk between reboots.
							execSync('cp ' + self._orgEepromFilePath + ' ' + self._eepromFilePath);
							resolve(ee);
						}
					});
				} catch(err){
					logerr("Write caught exception failed ", err);
					clearInterval(interval);
					reject(err);
				}
			});
		}

		function update_identity() {
			return new Promise((resolve, reject) => {
				logdbg("In install EEPROM function");
				process.stdout.write("Writing...");
				let interval = setInterval(() => {
					process.stdout.write(".");
				}, 500);
				try {
					fs.writeFile(self._eepromFilePath, JSON.stringify(ee, null, 4), 'utf8', (err) => {
						if(err) {
							logerr("Write failed " + err);
							clearInterval(interval);
							reject(err);
						} else {
							clearInterval(interval);
							loginfo('Wrote successfully!');
							resolve(ee);
						}
					});
				} catch(err){
					logerr("Write caught exception failed ", err);
					clearInterval(interval);
					reject(err);
				}
			});
		}

		if(obj.op == 'new') {
			return write_new_identity();
		} else if (obj.op == 'update') {
			return update_identity();
		}
	}

	process_prog() {
		var self = this;

		return new Promise(function(resolve, reject) {
			if(fs.existsSync(self._orgEepromFilePath)) {
				// Yes, original identity exists, it can mean 2 things
				// 1. Writing new identity with same serial number after edge-core is connected and got new deviceID. Check for deviceID and if not same then write the identity.json
				// 2. If serial numbers are different, then ask user to factory erase and then try again.
				// If neither of the criteria are met then abort
				try {
					let org_ee = JSON.parse(jsonminify(fs.readFileSync(self._orgEepromFilePath, 'utf8')));
					let new_ee = JSON.parse(jsonminify(fs.readFileSync(program.args[0], 'utf8')));
					// Condition 1, If same serial number and different deviceID
					if((org_ee.serialNumber == new_ee.serialNumber) && (org_ee.deviceID != new_ee.deviceID)) {
						loginfo('Same serial number as provisioning but new deviceID. Edge-core must have been claimed!');
						resolve({ ee: new_ee, op: 'update'});
						return;
					}
					// Condition 2, if different serial number then exit
					if(org_ee.serialNumber === new_ee.serialNumber) {
						logerr('You are trying to write the identity with the same deviceID and serialNumber. To continue, first factory erase! Use the factory erase script in gateway utilities directory.');
						reject();
						return;
					}
				} catch(err) {
					logerr("Failed to read identity file- ", err);
					reject(err);
				}
			} else {
				// No, identity do not exists. Brand new gateway
				try {
					let ee = JSON.parse(jsonminify(fs.readFileSync(program.args[0], 'utf8')));
					if( (ee.cloudURL && ee.cloudURL.indexOf('mbed') > -1) || (ee.cloudAddress && ee.cloudAddress.indexOf('mbed') > -1)) {
						if(!ee.mcc_config) {
							fs.stat('./pal', function(err, stats) {
								if(err) {
									logerr('Mbed gateway. Failed to get pal directory stats ', err);
									reject(err);
									return;
								}
								if(stats.isDirectory()) {
									execSync('cp -R ./pal ./mcc_config');
									execSync('tar -czvf mcc_config.tar.gz ./mcc_config');
									delete ee.mbed;
									ee.mcc_config = fs.readFileSync('./mcc_config.tar.gz', 'hex');
									resolve({ee: ee, op: 'new'});
								} else {
									logerr('Mbed gateway. Failed to locate pal directory!')
									reject();
									return;
								}
							});
						} else {
							resolve({ee: ee, op: 'new'});
						}
					} else {
						resolve({ee: ee, op: 'new'});
					}
				} catch(err) {
					logerr("Failed to read identity file- ", err);
					reject(err);
				}
			}
		})
	}
}

// //For Relay
// class at24c16EepromHandler {
// 	constructor() {
// 		this.EEwriter = require('./eewriter_module.js');
// 	}

// 	process_prog() {
// 		return new Promise((resolve, reject) => {
// 			if (program.args.length != 1 && program.erase === null) {
// 				program.outputHelp();
// 				reject("Missing configuration file");
// 			}
// 			else {
// 				try {
// 					let ee = JSON.parse(jsonminify(fs.readFileSync(program.args[0], 'utf8')));
// 					//Add sixBMAC as it is removed from the relay eeprom from provisiong server
// 					//Make it compatible with existing requirement on eeprom writer
// 					if(typeof ee.sixBMAC == 'undefined') {
// 						ee.sixBMAC = JSON.parse(JSON.stringify(ee.ethernetMAC));
// 						ee.sixBMAC.splice(3, 0, 0);
// 						ee.sixBMAC.splice(4, 0, 1);
// 					}
// 					ee.relaySecret =  ee.relaySecret || "17c0c7bd1c7f8a360288ef56b4230ede";
// 					ee.batch = ee.batch || '1';
// 					ee.month = ee.month || 'F';
// 					ee.year = ee.year || '5';
//                     if( (ee.cloudURL && ee.cloudURL.indexOf('mbed') > -1) || (ee.cloudAddress && ee.cloudAddress.indexOf('mbed') > -1)) {
//                     	//TODO- This is deleted on upgrade so refer this or find out if something exists in /userdata/mbed/mcc_config
// 						if(!ee.mcc_config) {
// 	                        fs.stat('./pal', function(err, stats) {
// 	                            if(err) {
// 	                                reject('Mbed gateway. Failed to get pal directory stats ', err);
// 	                                return;
// 	                            }
// 	                            if(stats.isDirectory()) {
// 	                                execSync('cp -R ./pal ./mcc_config');
// 	                                execSync('tar -czvf mcc_config.tar.gz ./mcc_config');
// 	                                // if(ee.mbed) {
// 	                                    delete ee.mbed;
// 	                                    ee.mcc_config = fs.readFileSync('./mcc_config.tar.gz', 'hex');
// 	                                    resolve(ee);
// 	                                // } else {
// 	                                    // reject('Mbed gateway. Did not find the mbed device certs and enrollment id!');
// 	                                    // return;
// 	                                // }
// 	                            } else {
// 	                                reject('Mbed gateway. Failed to locate pal directory!');
// 	                                return;
// 	                            }
// 	                        });
// 	                    } else {
// 	                    	resolve(ee);
// 	                    }
//                     } else {
//                         resolve(ee);
//                     }
// 					// resolve(ee);
// 				}
// 				catch (e) {
// 					reject('Could not open ' + program.args[0] + ' file', e + ' ', e.stack);

// 				}
// 			}
// 		});
// 	}

// 	install_eeprom(ee) {
// 		var self = this;
// 		return new Promise((resolve, reject) => {
// 			logdbg("In install EEPROM Function");
// 			//logdbg(ee);
// 			let aPray2= [];
// 			let writer = new self.EEwriter(ee);

// 			if (!program.skipeeprom) {
// 				loginfo("didnnt skip eeprom");
// 				aPray2.push(writer.writeEMMC());
// 			}
// 			if (!program.skipSSL) {
// 				loginfo("didnnt skip ssl");
// 				aPray2.push(writer.writeSSL());
// 			}
// 			Promise.all(aPray2).then((suc) => {
// 				loginfo("ie: " + suc);
// 				resolve(suc);
// 			}, (err) => {
// 				loginfo("iee: " + err);
// 				reject(err);
// 			});
// 		});
// 	}

// 	main_erase() {
// 		var self = this;
// 		loginfo("main erase");
// 		return new Promise((resolve, reject) => {
// 			let writer = new self.EEwriter();
// 			writer.erase().then((result) => {
// 				loginfo("debug", "erase resolved: ", result);
// 				resolve(result);
// 			}).catch((error) => {
// 				loginfo("debug", "erase errored: ", error);
// 				reject(error);
// 			});
// 		});

// 	}

// 	main_install() {
// 		let self = this;
// 		this.process_prog().then((result) => {
// 			loginfo("debug", "process_program resolved: ");
// 			return self.install_eeprom(result);
// 		}).catch((error) => {
// 			loginfo("debug", "process_program errored: ", error);
// 		});
// 	}
// }

// const at24c256EepromFilePath = "/sys/bus/i2c/devices/1-0050/eeprom";

// //For RP200 and above
// class at24c256EepromHandler {
// 	constructor() {
// 		this._eepromFilePath = at24c256EepromFilePath;
// 		this._writeretry = 0;
// 	}

// 	verify_write(ee) {
// 		let self = this;
// 		process.stdout.write('Verifying...');
// 	 	let interval = setInterval(() => {
// 			process.stdout.write(".");
// 		}, 500);
// 		return new Promise((resolve, reject) => {
// 			let readEeprom = fs.readFileSync(self._eepromFilePath, 'utf8');
// 			clearInterval(interval);
// 			try {
// 				readEeprom = JSON.parse(readEeprom);
// 			} catch(err) {
// 				logerr('Failed to parse ', err);
// 				reject(err);
// 				process.exit(1);
// 				return;
// 			}
// 			if(_.isEqual(ee, readEeprom)) {
// 				loginfo('\nVerification successfully\n');
// 				loginfo('Saving the gateway eeprom on disk at /userdata/gateway_eeprom.json');
// 				fs.writeFileSync('/userdata/gateway_eeprom.json', JSON.stringify(ee, null, 4), 'utf8');
// 				resolve();
// 			} else {
// 				logerr('\nVerification failed!\n');
// 				reject('Verification failed!');
// 				process.exit(1);
// 			}
// 		});
// 	}

// 	process_prog() {
// 		return new Promise((resolve, reject) => {
// 			if (program.args.length != 1 && program.erase === null) {
// 				program.outputHelp();
// 				reject("Missing configuration file");
// 			}
// 			else {
// 				try {
// 					let ee = JSON.parse(jsonminify(fs.readFileSync(program.args[0], 'utf8')));
//                     if( (ee.cloudURL && ee.cloudURL.indexOf('mbed') > -1) || (ee.cloudAddress && ee.cloudAddress.indexOf('mbed') > -1)) {
//                     	//TODO- This is deleted on upgrade so refer this or find out if something exists in /userdata/mbed/mcc_config
//                         if(!ee.mcc_config) {
// 	                        fs.stat('./pal', function(err, stats) {
// 	                            if(err) {
// 	                                reject('Mbed gateway. Failed to get pal directory stats ', err);
// 	                                return;
// 	                            }
// 	                            if(stats.isDirectory()) {
// 	                                execSync('cp -R ./pal ./mcc_config');
// 	                                execSync('tar -czvf mcc_config.tar.gz ./mcc_config');
// 	                                // if(ee.mbed) {
// 	                                    delete ee.mbed;
// 	                                    ee.mcc_config = fs.readFileSync('./mcc_config.tar.gz', 'hex');
// 	                                    resolve(ee);
// 	                                // } else {
// 	                                    // reject('Mbed gateway. Did not find the mbed device certs and enrollment id!');
// 	                                    // return;
// 	                                // }
// 	                            } else {
// 	                                reject('Mbed gateway. Failed to locate pal directory!');
// 	                                return;
// 	                            }
// 	                        });
// 	                    } else {
// 	                    	resolve(ee);
// 	                    }
//                     } else {
//                         resolve(ee);
//                     }
// 				}
// 				catch (e) {
// 					reject('Could not open ' + program.args[0] + ' file', e + ' ', e.stack);

// 				}
// 			}
// 		});
// 	}

//     install_eeprom(ee) {
//         var self = this;
//         return new Promise((resolve, reject) => {
//             logdbg("In install EEPROM function");
//             process.stdout.write("Writing...");
//             let interval = setInterval(() => {
//                 process.stdout.write(".");
//             }, 500);
//             try {
//                 fs.writeFile(self._eepromFilePath, JSON.stringify(ee), 'utf8', (err) => {
//                     if(err) {
// 						logerr("Write failed " + err);
// 						clearInterval(interval);
// 						reject(err);
//                     } else {
//                         clearInterval(interval);
//                         loginfo('Wrote successfully!');
//                         resolve(ee);
//                     }
//                 });
//             } catch(err){
//                 logerr("Write caught exception failed ", err);
//                 clearInterval(interval);
//                 reject(err);
//             }
//         });
//     }

//     main_erase() {
//         let self = this;
//         return new Promise((resolve, reject) => {
//             loginfo("main erase");
//             let eeprom_spaces = new Buffer(32768);
//             eeprom_spaces.fill(0x20);
//             process.stdout.write("Erasing...");
//             let interval = setInterval(() => {
//                 process.stdout.write(".");
//             }, 500);
//             try {
//                 fs.writeFile(self._eepromFilePath, eeprom_spaces, (err) => {
//                     if(err) {
// 						logerr("Erase failed " + err);
// 						clearInterval(interval);
// 						reject(err);
//                     } else {
//                         clearInterval(interval);
//                         loginfo('Erased successfully!');
//                         resolve();
//                     }
//                 });
//             } catch(err) {
//                 logerr("Erase caught exception failed ", err);
//                 clearInterval(interval);
//                 reject(err);
//             }
//         });
//     }

// 	main_install() {
// 		let self = this;
// 		return new Promise((resolve, reject) => {
// 			self.process_prog().then((result) => {
// 				loginfo("debug", "process_program resolved: ");
// 				self.install_eeprom(result).then((resp) => {
// 					resolve(resp);
// 				}).catch((error) => {
// 					logerr('Failed to write ', error);
// 					reject(error);
// 				});
// 			}).catch((error) => {
// 				loginfo("debug", "process_program errored: ", error);
// 				reject(error);
// 			});
// 		});
// 	}
// }


if (program.args.length != 1) {
	program.outputHelp();
	process.exit(1);
}

let softGateway = new softEepromHandler();
softGateway.init_eeprom().then(function() {
	softGateway.process_prog().then(function(obj) {
		softGateway.install_eeprom(obj).then(function() {
			softGateway.cleanup();
			loginfo('All done. Good bye!');
		}, function(err) {
			process.exit(1);
		});
	}, function(err) {
		process.exit(1);
	});
}, function(err) {
	process.exit(1);
});




//DEPRECATED: As new platforms will not have EEPROM so we are no longer support the old EEPROMs.
//Save the edge configuration/identity file on read-only FS.

//To check which hardware we are on check if eeprom file exists then use new eeprom handlers
// if(fs.existsSync(at24c256EepromFilePath)) {
// 	let rp200Eeprom = new at24c256EepromHandler();
// 	if(program.erase) {
// 		rp200Eeprom.main_erase();
// 	} else if(program.verify) {
// 		rp200Eeprom.process_prog().then((result) => {
// 			return rp200Eeprom.verify_write(result);
// 		}).catch((err) => {
// 			logerr('Failed to process ', err);
// 		});
// 	} else {
// 		rp200Eeprom.main_erase().then(() => {
// 			rp200Eeprom.main_install().then((result) => {
// 				rp200Eeprom.verify_write(result).then(function() {

// 				}, function(err) {
// 					logerr('Erase failed ', err);
// 					process.exit(1);
// 				})
// 			}, function(err) {
// 				logerr('Erase failed ', err);
// 				process.exit(1);
// 			});
// 		}, (err) => {
// 			logerr('Erase failed ', err);
// 			process.exit(1);
// 		});
// 	}
// } else {
// 	let relayEeprom = new at24c16EepromHandler();
// 	if(program.erase) {
// 		relayEeprom.main_erase();
// 	} else {
// 		relayEeprom.main_erase().then(() => {
// 			relayEeprom.main_install();
// 		}, (err) => {
// 			logerr('Erase failed ', err);
// 			process.exit(1);
// 		});
// 	}
// }


process.on('unhandledRejection', error => {
	logerr('unhandledRejection' + JSON.stringify(error.message) + ' errstack- ', error.stack);
	process.exit(1);
});