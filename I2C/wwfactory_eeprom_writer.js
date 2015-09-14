var EEwriter = require('./eewriter_module.js');
var Promise = require('es6-promise').Promise;
var program = require('commander');
var fs = require('fs');
optionspassed = false;

var eeprom_obj = "";

function erase_eeprom() {
	return new Promise(function(resolve, reject) {
		var ewriter = new EEwriter();
		ewriter.erase().then(function(suc) {
			resolve("success");
		}, function(err) {
			reject(err);
		});
	});
}

function validate_version(v) {
	optionspassed = true;
	switch (v) {
		case "0.0.1":
		case "0.0.2":
		case "0.0.3":
		case "0.0.4":
		case "0.0.5":
		case "0.0.6":
		case "0.0.7":
		case "0.0.8":
			return v;
			break;
		default:
			console.log(v + " is not a valid board version.");
			return false;
			break;
	}
}

program
	.version('0.0.1')
	.usage('[options] <file ...>')
	.option('-b, --boardversion <v>', 'update the board version', validate_version)
	.option('-e, --erase', 'erase the eeprom')
	.parse(process.argv);

if (program.boardversion || program.erase) {
	hasoptions = true;
}

if (program.args.length == 0 && optionspassed) {
	if (program.erase) {
		console.log("erasing eeprom");
		erase_eeprom();
	}
	if (program.boardversion) {
		var writer = new EEwriter();
		writer.write_one("hardwareVersion", program.boardversion).then(function(suc) {
			console.log("Succesfully updated board version to " + program.boardversion);
		}, function(err) {
			console.log("err");
		});
	}

}
else {
	readfile = "eeprom.json";
	if (program.args.length > 0) readfile = program.args[0];
	fs.readFile(readfile, 'utf8', function(err, data) {
		if (err) {
			console.log("file " + program.args[0] + " does not exist");
			throw err;
		}
		try {
			eeprom_obj = JSON.parse(data);
			var writer = new EEwriter(eeprom_obj);
			writer.write().then(function(suc) {
				console.log("Successfully wrote eeprom ");
			}, function(err) {
				console.log("Error " + err);
			});
		}
		catch (e) {
			console.log(program.args[0] + " Not a valid json file (" + e + ")");
		}
	});
}