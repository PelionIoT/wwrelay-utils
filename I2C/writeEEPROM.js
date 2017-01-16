var EEwriter = require('./eewriter_module.js');
var fs = require('fs');
var exec = require('child_process').exec;
var execSync = require('child_process').execSync;
var Promise = require('es6-promise').Promise;
// var execSync = require('execSync');
var flatten = require('flat');
var jsonminify = require('jsonminify');
var path = require('path');
var handleBars = require('handlebars');
var program = require('commander');

program
	.version('0.0.1')
	.option('-e, --erase', 'Erase the eeprom')
	.option('-s --skipeeprom', 'skip the eeprom portion')
	.option('-S --skipSSL', 'skip the ssl portion')
	.parse(process.argv);

program.on('--help', function() {
	console.log(' Examples:');
	console.log("");
	console.log("  $ node writeEEPROM.js <config.json>");
});

function process_prog() {
	return new Promise(function(resolve, reject) {
		if (program.args.length != 1 && program.erase == null) {
			program.outputHelp();
			reject("Missing configuration file");
		}
		else {
			try {
				var ee = JSON.parse(jsonminify(fs.readFileSync(program.args[0], 'utf8')));
				resolve(ee);
			}
			catch (e) {
				reject('Could not open ' + program.args[0] + ' file', e);

			}
		}
	});
}

function install_eeprom(ee) {
	return new Promise(function(resolve, reject) {
		console.log('debug', "In install EEPROM Function");
		//console.log('debug', ee);
		aPray2 = new Array();
		var writer = new EEwriter(ee);

		if (!program.skipeeprom) {
			console.log("didnnt skip eeprom");
			aPray2.push(writer.writeEMMC());
		}
		if (!program.skipSSL) {
			console.log("didnnt skip ssl");
			aPray2.push(writer.writeSSL());
		}
		Promise.all(aPray2).then(function(suc) {
			console.log("ie: " + suc);
			resolve(suc);
		}, function(err) {
			console.log("iee: " + err);
			reject(err);
		});
	});
}

function main_install() {
	process_prog().then(function(result) {
		console.log("debug", "process_program resolved: ");
		return install_eeprom(result);
	}).catch(function(error) {
		console.log("debug", "process_program errored: ", error);
	});
}

function main_erase() {
	console.log("main erase");
	var writer = new EEwriter();
	writer.erase().then(function(result) {
		console.log("debug", "erase resolved: ", result);
	}).catch(function(error) {
		console.log("debug", "erase errored: ", error);
	});
}

if (program.erase) {
	main_erase();
}
else {
	main_install();
}