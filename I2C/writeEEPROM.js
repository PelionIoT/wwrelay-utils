'use strict';

const EEwriter = require('./eewriter_module.js');
const fs = require('fs');
const exec = require('child_process').exec;
const execSync = require('child_process').execSync;
const flatten = require('flat');
const jsonminify = require('jsonminify');
const path = require('path');
const handleBars = require('handlebars');
const program = require('commander');
const _ = require('underscore');

program
	.version('0.0.1')
	.option('-e, --erase', 'Erase the eeprom')
	.option('-s --skipeeprom', 'skip the eeprom portion')
	.option('-S --skipSSL', 'skip the ssl portion')
	.option('-v --verify', 'verify eeprom write')
	.parse(process.argv);

program.on('--help', () => {
	console.log(' Examples:');
	console.log("");
	console.log("  $ node writeEEPROM.js <config.json>");
});

const at24c256EepromFilePath = "/sys/bus/i2c/devices/1-0050/eeprom";

//For Relay
class at24c16EepromHandler {
	constructor() {

	}

	process_prog() {
		return new Promise((resolve, reject) => {
			if (program.args.length != 1 && program.erase === null) {
				program.outputHelp();
				reject("Missing configuration file");
			}
			else {
				try {
					let ee = JSON.parse(jsonminify(fs.readFileSync(program.args[0], 'utf8')));
					resolve(ee);
				}
				catch (e) {
					reject('Could not open ' + program.args[0] + ' file', e);

				}
			}
		});
	}

	install_eeprom(ee) {
		return new Promise((resolve, reject) => {
			console.log('debug', "In install EEPROM Function");
			//console.log('debug', ee);
			let aPray2= [];
			let writer = new EEwriter(ee);

			if (!program.skipeeprom) {
				console.log("didnnt skip eeprom");
				aPray2.push(writer.writeEMMC());
			}
			if (!program.skipSSL) {
				console.log("didnnt skip ssl");
				aPray2.push(writer.writeSSL());
			}
			Promise.all(aPray2).then((suc) => {
				console.log("ie: " + suc);
				resolve(suc);
			}, (err) => {
				console.log("iee: " + err);
				reject(err);
			});
		});
	}

	main_erase() {
		console.log("main erase");
		return new Promise((resolve, reject) => {
			let writer = new EEwriter();
			writer.erase().then((result) => {
				console.log("debug", "erase resolved: ", result);
				resolve(result);
			}).catch((error) => {
				console.log("debug", "erase errored: ", error);
				reject(error);
			});
		});
		
	}

	main_install() {
		let self = this;
		this.process_prog().then((result) => {
			console.log("debug", "process_program resolved: ");
			return self.install_eeprom(result);
		}).catch((error) => {
			console.log("debug", "process_program errored: ", error);
		});
	}
}


//For RP200 and above
class at24c256EepromHandler {
	constructor() {
		this._eepromFilePath = at24c256EepromFilePath;
	}

	verify_write(ee) {
		let self = this;
		process.stdout.write('Verifying...');
	 	let interval = setInterval(() => {
			process.stdout.write(".");
		}, 500);
		return new Promise((resolve, reject) => {
			let readEeprom = fs.readFileSync(self._eepromFilePath, 'utf8');
			clearInterval(interval);
			try {
				readEeprom = JSON.parse(readEeprom);
			} catch(err) {
				console.error('Failed to parse ', err);
				reject(err);
				process.exit(1);
				return;
			} 
			if(_.isEqual(ee, readEeprom)) {
				console.log('\nVerification successfully\n');
				resolve();
			} else {
				console.error('\nVerification failed!\n');
				reject('Verification failed!');
				process.exit(1);
			}
		});
	}

	process_prog() {
		return new Promise((resolve, reject) => {
			if (program.args.length != 1 && program.erase === null) {
				program.outputHelp();
				reject("Missing configuration file");
			}
			else {
				try {
					let ee = JSON.parse(jsonminify(fs.readFileSync(program.args[0], 'utf8')));
					resolve(ee);
				}
				catch (e) {
					reject('Could not open ' + program.args[0] + ' file', e);

				}
			}
		});
	}

	install_eeprom(ee) {
		return new Promise((resolve, reject) => {
			console.log('debug', "In install EEPROM Function");
			process.stdout.write("Writing...");
		 	let interval = setInterval(() => {
				process.stdout.write(".");
			}, 500);
			fs.writeFile(this._eepromFilePath, JSON.stringify(ee), 'utf8', (err) => {
				if(err) {
					console.error("Write failed ", err);
					reject(err);
					return;
				}
				clearInterval(interval);
				console.log('Wrote successfully!');
				resolve(ee);
			});
		});
	}

	main_erase() {
		let self = this;
		return new Promise((resolve, reject) => {
			console.log("main erase");
			let eeprom_spaces = new Buffer(32768);
			eeprom_spaces.fill(0x20);
			process.stdout.write("Erasing...");
		 	let interval = setInterval(() => {
				process.stdout.write(".");
			}, 500);
			fs.writeFile(self._eepromFilePath, eeprom_spaces, (err) => {
				if(err) {
					console.error("Erase failed ", err);
					reject(err);
					return;
				}
				clearInterval(interval);
				console.log('Erased successfully!');
				resolve();
			});
		});
	}

	main_install() {
		let self = this;
		return new Promise((resolve, reject) => {
			self.process_prog().then((result) => {
				console.log("debug", "process_program resolved: ");
				self.install_eeprom(result).then((resp) => {
					resolve(resp);
				}).catch((error) => {
					console.error('Failed to write ', error);
					reject(error);
				});
			}).catch((error) => {
				console.log("debug", "process_program errored: ", error);
				reject(error);
			});
		});
	}
}


//To check which hardware we are on check if eeprom file exists then use new eeprom handlers 
if(fs.existsSync(at24c256EepromFilePath)) {
	let rp200Eeprom = new at24c256EepromHandler();
	if(program.erase) {
		rp200Eeprom.main_erase();
	} else if(program.verify) {
		rp200Eeprom.process_prog().then((result) => {
			return rp200Eeprom.verify_write(result);
		}).catch((err) => {
			console.error('Failed to process ', err);
		});
	} else {
		rp200Eeprom.main_erase().then(() => {
			rp200Eeprom.main_install().then((result) => {
				rp200Eeprom.verify_write(result);
			});
		}, (err) => {
			console.error('Erase failed ', err);
			process.exit(1);
		});
	}
} else {
	let relayEeprom = new at24c16EepromHandler();
	if(program.erase) {
		relayEeprom.main_erase();
	} else {
		relayEeprom.main_erase().then(() => {
			relayEeprom.main_install();
		}, (err) => {
			console.error('Erase failed ', err);
			process.exit(1);
		});
	}
}