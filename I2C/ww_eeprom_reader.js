#!/usr/bin/env node

var WWAT24 = require('./WWrelay_at24c16.js');
reader = new WWAT24();
//r/w files
var fs = require('fs');
var exec = require('child_process').exec;
var execSync = require('child_process').execSync;
// var execSync = require('execSync');
var flatten = require('flat');
var jsonminify = require('jsonminify');
var path = require('path');
var handleBars = require('handlebars');


var template_conf_file = "/wigwag/devicejs-core-modules/Runner/template.config.json";
var relay_conf_json_file = "/wigwag/devicejs-core-modules/Runner/relay.config.json";
var devjsconf = JSON.parse(jsonminify(fs.readFileSync(template_conf_file, 'utf8')));

var cloudURL = "https://cloud.wigwag.com";
var overwrite_conf = false;

var hardware_conf = "./relay.conf";
// var relayconf_dot_sh = "/etc/wigwag/relayconf.sh"
// var hw_dot_conf = "/etc/wigwag/hardware.conf"
var eeprom_dot_json = "/etc/wigwag/eeprom.json";
var uuid_eeprom_path = "/etc/wigwag/.eeprom_";

function flattenobj(obj, callback) {
	var out = flatten(obj, {
		delimiter: "_",
		safe: true
	});
	var str = "";
	Object.keys(out).forEach(function(key) {
		str += key + "=\"" + out[key] + "\"\n";
	});
	callback(str);
}

function read(ray, str, callback) {
	var key = ray.shift();
	//console.log("read(%s %s) and the key: %s", key, str, key);
	reader.get(key).then(function(res) {
		var ray2 = ray;
		var str2 = str;
		if (res) {
			//this will convert the storred hex to integers array
			if (key == "ethernetMAC" || key == "sixBMAC") {
				newray = [];
				var newstr = "";
				var tempi = 0;
				for (var i = 0; i < res.length; i++) {
					tempi = res.readUInt8(i);
					temps = tempi.toString(16);
					if (temps.length == 1) temps += "0";
					newray.push(tempi);
					newstr += temps;
				};
				str2 += "\"" + key + "\": { \"string\":";

				str2 += "\"" + newstr + "\",";
				str2 += "\"" + "array\":";
				str2 += "[" + newray + "]}";
			}
			else {
				str2 += "\"" + key + "\":";
				str2 += "\"" + res + "\"";
			}
			if (ray2.length > 0) {
				str2 += ",";
				read(ray2, str2, callback);
			}
			else {
				str2 += "}";
				callback(str2);
			}
		}
	});
}

function define_hardware(res) {
	var GPIOpath = "/sys/class/gpio/";
	var LEDspath = "/sys/class/leds";
	// var hardwareProfile = new Object();
	// var radioProfile = new Object();
	hw = new Object();
	hw.gpioProfile = new Object();
	hw.radioProfile = new Object();
	//console.log("Here iam and res hwadwareverssion: " + res.hardwareVersion.toString());
	switch (res.hardwareVersion.toString()) {
		case "0.0.0":
			hw.gpioProfile.RelayType = "software";
			hw.radioProfile.hasSM_SBMC = false; //Solder_Module 6BEE MC13224
			hw.radioProfile.hasSM_5304 = false; //Solder_Module Zwave 5304
			hw.radioProfile.hasSM_U880 = false; //Solder_Module U880
			hw.radioProfile.hasSM_BT = false; //Solder_Module Bluetooth
			hw.radioProfile.SBMC_TTY = "/dev/ttyUSB0"
			break;
		case "0.0.1":
		case "0.0.2":
		case "0.0.4":
		case "0.0.5":
		case "0.0.6":
		case "0.0.7":
		case "0.0.8":
			hw.gpioProfile.NumberOfInputs = 1;
			hw.gpioProfile.NumberOfOutputs = 11;
			hw.gpioProfile.RelayType = "hardware";
			hw.gpioProfile.RED_OFF = GPIOpath + "gpio11_pb8";
			hw.gpioProfile.BUTTON = GPIOpath + "gpio12_ph12";
			hw.gpioProfile.TopRed = LEDspath + "/red";
			hw.gpioProfile.TopBlue = LEDspath + "/blue";
			hw.gpioProfile.TopGreen = LEDspath + "/green";
			hw.radioProfile.hasSM_SBMC = true; //Solder_Module 6BEE MC13224
			hw.radioProfile.hasSM_5304 = false; //Solder_Module Zwave 5304
			hw.radioProfile.hasSM_U880 = false; //Solder_Module U880
			hw.radioProfile.hasSM_BT = false; //Solder_Module Bluetooth
			hw.radioProfile.SBMC_TTY = "/dev/ttyS6";
			hw.radioProfile.CC2530_TTY = "/dev/ttyS1";
			hw.radioProfile.SBMC_ERASE = GPIOpath + "gpio3_pd2";
			hw.radioProfile.SBMC_RESET = GPIOpath + "gpio1_pd0";
			hw.radioProfile.SBMC_RTS = GPIOpath + "gpio2_pd1";
			hw.radioProfile.ZWAVE_TTY = "/dev/ttyS5";
			hw.radioProfile.ZWAVE_ERASE = GPIOpath + "gpio4_pd3";
			hw.radioProfile.CC2530_RESET = GPIOpath + "gpio5_pd4";
			hw.radioProfile.CC2530_DBG_DATA = GPIOpath + "gpio7_pd6";
			hw.radioProfile.CC2530_DBG_CLK = GPIOpath + "gpio6_pd5";
			break;
	};

	///may need to nest this swtich into the above in the future... just make it a huge decision tree
	// switch (res.radioConfig) {
	// 	case "00":

	// 		break;
	// 	case "01":

	// 		break;
	// 	case "04":

	// 		break;
	// }
	return hw;
}

function createHandlebarsData(eeprom) {
	var data = {};

	data.apikey = eeprom.relayID;
	data.apisecret = eeprom.relaySecret;
	data.cloudurl = eeprom.cloudURL;
	data.zwavetty = eeprom.hardware.radioProfile.ZWAVE_TTY;
	data.sixlbrtty = eeprom.hardware.radioProfile.SBMC_TTY;
	data.sixbmac = eeprom.sixBMAC.string;
	data.ethernetmac = eeprom.ethernetMAC.string;

	return data;
}

function modify_devjs(MAC, TTY) {
	devjsconf.runtimeConfig.services.sixLBR.config.sixlbr.siodev = TTY;
	devjsconf.runtimeConfig.services.sixLBR.config.sixlbr.sixBMAC = MAC;
}

function get_all(callback) {
	str = "{";
	first = true;
	var temp = [];
	for (var attr in reader.Layout) {
		temp.push(attr);
	}
	var res;
	read(temp, str, function(done) {
		try {
			var res = JSON.parse(done);
		}
		catch (e) {
			callback(JSON.parse('{"eeprom":"not configured properly"}'));
		}
		res.relayID = res.BRAND + res.DEVICE + res.UUID;
		res.cloudURL = cloudURL;
		callback(res);
	});
}

function write_JSON2file(myfile, json, overwrite, cb) {
	console.log("writing: %s:%s", myfile, json);
	fs.exists(myfile, function(exists) {
		if (exists && overwrite || (!exists)) {
			fs.writeFile(myfile, JSON.stringify(json, null, '\t') + "\n", 'utf8', function(err) {
				if (err) {
					cb(err, null);
				}
				else {
					cb(null, "SUCCESS");
				}
			});
		}
		else {
			console.log('NOTE: file ' + myfile + ' exists and overwrite false');
			cb(null, "SUCCESS");
		}
	});
}

function write_string2file(myfile, str, overwrite, cb) {
	console.log("writing: %s", myfile);
	fs.exists(myfile, function(exists) {
		if (exists && overwrite || (!exists)) {
			fs.writeFile(myfile, str, 'utf8', function(err) {
				if (err) {
					cb(err, null);
				}
				else {
					cb(null, "SUCCESS");
				}
			});
		}
		else cb(null, "SUCCESS");
	});
}

function MACarray2string(mray) {
	var finalstring = "";
	var temps = "";
	for (var i = 0; i < mray.length; i++) {
		temps = mray[i].toString(16);
		if (temps.length == 1) temps += "0";
		finalstring += temps;
	};
	return finalstring;
}

function eeprom2relay(uuid_eeprom, callback) {
	var R = new Object();
	var ethernetMAC = new Object();
	var sixBMAC = new Object();
	var CI = require(uuid_eeprom);
	R.BRAND = CI.relayID.substring(0, 2);
	R.DEVICE = CI.relayID.substring(2, 4);
	R.UUID = CI.relayID.substring(4, 10);
	R.hardwareVersion = CI.hardwareVersion;
	R.firmwareVersion = "-----";
	R.radioConfig = CI.radioConfig;
	R.year = CI.year;
	R.month = CI.month;
	R.batch = CI.batch;
	ethernetMAC.string = MACarray2string(CI.ethernetMAC);
	ethernetMAC.array = CI.ethernetMAC;
	sixBMAC.string = MACarray2string(CI.sixBMAC);
	sixBMAC.array = CI.sixBMAC;
	R.ethernetMAC = ethernetMAC;
	R.sixBMAC = sixBMAC;
	R.relaySecret = CI.relaySecret;
	R.pairingCode = CI.pairingCode;
	R.relayID = CI.relayID;
	R.cloudURL = CI.cloudURL;
	callback(null, R);
}

function read_sw_eeprom(callback) {
	var uuid = execSync.exec('dmidecode -s system-uuid');
	var uuid_eeprom = uuid_eeprom_path + uuid.stdout.toString().trim() + ".json";
	fs.exists(uuid_eeprom, function(exists) {
		if (!exists) { //read eeprom.json and build the uuid eeprom, then delete the eeprom.json
			fs.rename(eeprom_dot_json, uuid_eeprom, function(err, suc) {
				if (err) {
					console.log("Error: %s OR %s does not exist.  Is this a new virtual_relay or a clonded virtual relay? Request a eeprom.json from \"Walt\"--> to be replaced with http://developer.wigwag.com or whatever", uuid_eeprom, eeprom_dot_json);
					callback("no_eeprom", null);
				}
				else {
					eeprom2relay(uuid_eeprom, callback);
				}
			});
		}
		else {
			eeprom2relay(uuid_eeprom, callback);
		}

	});

}

//main fuction, first determines if we are on purpose based hardware (currently only detects WigWag Relays), or software.   It does this by detecting the EEprom type @ a specific location. 
function main() {
	// print process.argv
	process.argv.forEach(function (val, index, array) {
	  // console.log(index + ': ' + val);
	  if(index > 1) {
	  	cloudURL = array[2];
	  	if(index > 2)
	  		overwrite_conf = array[3];	
	  }
	});

	reader.exists(function(the_eeprom_exists) {
		if (the_eeprom_exists) {
			console.log("Hardware based Relay found.");
			//	if (!exists) {
			get_all(function(result) {
				//this checks if the eeprom had valid data.  I may want to add a different check, perhaps a eeprom_version number, so this file never need to change

				if (result.BRAND == "WW" || result.BRAND == "WD") {
					hw = define_hardware(result);
					result.hardware = hw;
					// flattenobj(result, function(output) {
					// 	write_string2file(relayconf_dot_sh, output, true, function(err, succ) {
					// 		if (err) console.log("Error Writing file %s", err);
					// 	});
					// });

					//replace the handlebars
					var template = handleBars.compile(JSON.stringify(devjsconf));
					var data = createHandlebarsData(result);
					var conf = JSON.parse(template(data));

					write_JSON2file(relay_conf_json_file, conf, overwrite_conf, function(err, suc) {
						if (err) {
							console.error("Error Writing file ", relay_conf_json_file, err);	
							return;
						} 

						console.log(suc + ': wrote ' + relay_conf_json_file + ' file successfully');

						write_JSON2file(hardware_conf, result, overwrite_conf, function(err, suc) {
							if (err) {
								console.error("Error Writing file ", hardware_conf, err);	
								return;
							} 
							console.log(suc + ': wrote ' + hardware_conf + ' file successfully');

						});
					});
				}
				else {
					console.log("EEPROM is not configured properly.\n---------------------------------\nIf " + hardware_conf + " + " + relayconf_dot_sh + " exist, will manually use those files. Otherwise, Relay will not start up properly.");

				}
			});

		}
		else { //eprom doesn't exist... must do other things.  Assume the relay.conf just exists in desired form
			console.log("Software based Relay found");
			read_sw_eeprom(function(err, res) {
				if (res) {
					res.hw = define_hardware(res);
					modify_devjs(res.sixBMAC.string, "ttyUSB0");
					write_JSON2file(hardware_conf, res, true, function(err, suc) {
						write_JSON2file(wigwag_conf_json_file, devjsconf, true, function(err, suc) {
							if (err) console.log("Error Writing file %s", err);
						});
					});
				}
			});
		}
	});
}

main();

//reader.readSpecial();