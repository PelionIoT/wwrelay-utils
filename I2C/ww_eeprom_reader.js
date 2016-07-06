#!/usr/bin/env node

var WWAT24 = require('./WWrelay_at24c16.js');
reader = new WWAT24();
var DiskStorage = require("./diskstore.js");
var diskprom = new DiskStorage("/dev/mmcblk0p1", "/mnt/.boot/", ".ssl");
var mkdirp = require('mkdirp');

//r/w files
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

var sslPathDefault = "/wigwag/devicejs-core-modules/Runner/.ssl/";
mkdirp.sync(sslPathDefault);
var ssl_client_key = "client.key.pem";
var ssl_client_cert = "client.cert.pem";
var ssl_server_key = "server.key.pem";
var ssl_server_cert = "server.cert.pem";
var ssl_ca_cert = "ca.cert.pem";
var ssl_ca_int = "intermediate.cert.pem";

var template_conf_file = null;
var radioProfile_template_conf_file = null;
var relay_conf_json_file = null;
var rsmi_conf_json_file = null;
var devicejs_conf_file = null;
var templateDevicejsConf = null;
var sw_eeprom_file = null;
var devjsconf = null;
var secConfObj = null;
var radioModuleConf = null;
var cloudDevicejsURL = null;
var cloudDdbURL = null;

var cloudURL = "https://cloud.wigwag.com";
var overwrite_conf = false;
var softwareBasedRelay = false;

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
					if (temps.length == 1) newstr += "0";
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
	hw.radioModule = new Object();
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
			hw.radioProfile.SBMC_TTY = "/dev/ttyS4";
			hw.radioProfile.CC2530_TTY = "/dev/ttyS1";
			hw.radioProfile.SBMC_ERASE = GPIOpath + "gpio3_pd2";
			hw.radioProfile.SBMC_RESET = GPIOpath + "gpio98/value";
			hw.radioProfile.SBMC_RTS = GPIOpath + "gpio2_pd1";
			hw.radioProfile.ZWAVE_TTY = "/dev/ttyS5";
			hw.radioProfile.ZWAVE_ERASE = GPIOpath + "gpio4_pd3";
			hw.radioProfile.ZIGBEEHA_TTY = "/dev/ttyS6";
			hw.radioProfile.CC2530_RESET = GPIOpath + "gpio5_pd4";
			hw.radioProfile.CC2530_DBG_DATA = GPIOpath + "gpio7_pd6";
			hw.radioProfile.CC2530_DBG_CLK = GPIOpath + "gpio6_pd5";
			break;

		case "0.0.9":
		case "0.1.0":
		case "0.1.1":
		default:
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
			hw.radioProfile.SBMC_TTY = "/dev/ttyS4";
			hw.radioProfile.CC2530_TTY = "/dev/ttyS1";
			hw.radioProfile.SBMC_ERASE = GPIOpath + "gpio3_pd2";
			hw.radioProfile.SBMC_RESET = GPIOpath + "gpio98/value";
			hw.radioProfile.SBMC_RTS = GPIOpath + "gpio2_pd1";
			hw.radioProfile.ZWAVE_TTY = "/dev/ttyS5";
			hw.radioProfile.ZWAVE_ERASE = GPIOpath + "gpio4_pd3";
			hw.radioProfile.ZIGBEEHA_TTY = "/dev/ttyS6";
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

function createHandlebarsData(eeprom, platform) {
	var data = {};

	data.apikey = eeprom.relayID;
	data.apisecret = eeprom.relaySecret;
	data.cloudurl = eeprom.cloudURL;
	data.zwavetty = eeprom.hardware.radioProfile.ZWAVE_TTY;
	data.zigbeehatty = eeprom.hardware.radioProfile.ZIGBEEHA_TTY;
	data.sixlbrtty = eeprom.hardware.radioProfile.SBMC_TTY.split("/")[2];
	data.sixlbrreset = eeprom.hardware.radioProfile.SBMC_RESET;
	data.sixbmac = eeprom.sixBMAC.string;
	data.ethernetmac = eeprom.ethernetMAC.string;
	data.wwplatform = platform;

	return data;
}

function createHandlebarsDataForRSMI(eeprom) {
	var data = {};

	data.hardwareVersion = eeprom.hardwareVersion;
	data.radioConfig = eeprom.radioConfig;

	return data;
}

function createHandlebarsDevicejsConf(eeprom) {
	var data = {};

	data.apikey = eeprom.relayID;
	data.clouddevicejsurl = cloudDevicejsURL;
	data.cloudddburl = cloudDdbURL;

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
		if (temps.length == 1) finalstring += "0";
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
	R.cloudURL = cloudURL;
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

function setupLEDGPIOs() {
	return new Promise(function(resolve, reject) {
		exec('echo 37 > /sys/class/gpio/export', function(error, stdout, stderr) {
			try {
				execSync('echo out > /sys/class/gpio/gpio37/direction');
				exec('echo 38 > /sys/class/gpio/export', function(error, stdout, stderr) {
					execSync('echo out > /sys/class/gpio/gpio38/direction');
					console.log('setupLEDGPIOs successful');
					resolve();
				});
			}
			catch (err) {
				console.error('setupLEDGPIOs failed: ', err);
				reject(err);
			}

		});
	});
}

function enableRTC() {
	return new Promise(function(resolve, reject) {
		var i2c = require('i2c');
		var i2cbus = '/dev/i2c-0';
		//the PMU AXP that is used on the relay can charge the RTC battery.  In order to successfully do so, we need to tell the PMU to charge at a voltage of 2.97.  This is enabled by writing an 0x82 into the data address 0x35, of the AXP Chip (@ address 0x35) on the i2c-0 bus.
		var chipaddress = 0x34;
		var recharge_register = 0x35;
		var recharge_data = 0x82; //decimal = 130;
		var cpuvoltage_register = 0x23;
		var cpu_data = 0x14;

		PMU = new i2c(chipaddress, {
			device: i2cbus
		});

		PMU.readBytes(recharge_register, 1, function(err, res) {
			if (err) {
				console.log("Error: %s", err);
				resolve(err);
			}
			if (res.readUInt8(0) != recharge_data) {
				console.log("Currently set to: 0x%s.  Setting to 0x82", res.readUInt8(0).toString(16));
				PMU.writeBytes(recharge_register, [recharge_data], function(err) {
					if (err) console.log("Error: %s", err);
				});
			}
			else {
				console.log("RTC battery is charging: we are currently set to 0x%s", res.readUInt8(0).toString(16));
			}
			resolve();
		});
	});

}

function writeSecurity() {
	return new Promise(function(resolve, reject) {
		var DProm = new Array();
		DProm.push(diskprom.cpFile(ssl_client_key, sslPathDefault + ssl_client_key, POM));
		DProm.push(diskprom.cpFile(ssl_client_cert, sslPathDefault + ssl_client_cert, POM));
		DProm.push(diskprom.cpFile(ssl_server_key, sslPathDefault + ssl_server_key, POM));
		DProm.push(diskprom.cpFile(ssl_server_cert, sslPathDefault + ssl_server_cert, POM));
		DProm.push(diskprom.cpFile(ssl_ca_cert, sslPathDefault + ssl_ca_cert, POM));
		DProm.push(diskprom.cpFile(ssl_ca_int, sslPathDefault + ssl_ca_int, POM));
		console.log("calling the big DProm");
		Promise.all(DProm).then(function(result) {
			diskprom.disconnect();
			console.log("debug", "get sslclientkey resolved: " + result);
			console.dir(result);
			resolve();
		}).catch(function(error) {
			diskprom.disconnect();
			console.log("debug", "get sslclientkey errored: " + error);
			reject(error);
		});
	});
}

function generateDevicejsConf(eeprom) {
	return new Promise(function(resolve, reject) {
		if (devicejs_conf_file) {
			var deviceConfHandlebars = handleBars.compile(JSON.stringify(templateDevicejsConf));
			var deviceConfData = createHandlebarsDevicejsConf(eeprom);
			var deviceConf = JSON.parse(deviceConfHandlebars(deviceConfData));

			write_JSON2file(devicejs_conf_file, deviceConf, overwrite_conf, function(err, suc) {
				if (err) {
					console.error("Error Writing file ", devicejs_conf_file, err);
					reject(err);
				} else {
					console.log(suc + ': wrote ' + devicejs_conf_file + ' file successfully');
					resolve();
				}
			});
		} else {
			reject(new Error('Please specify the devicejs config file path, got- ' + JSON.stringify(devicejs_conf_file)));
		}
	});
}

function generateRelayConf(eeprom, platform) {
	return new Promise(function(resolve, reject) {
		//replace the handlebars
		var template = handleBars.compile(JSON.stringify(devjsconf));
		var data = createHandlebarsData(eeprom, platform + eeprom.hardwareVersion.toString());
		var conf = JSON.parse(template(data));

		write_JSON2file(relay_conf_json_file, conf, overwrite_conf, function(err, suc) {
			if (err) {
				console.error("Error Writing file ", relay_conf_json_file, err);
				reject(err);
			} else {
				console.log(suc + ': wrote ' + relay_conf_json_file + ' file successfully');
				resolve();
			}
		});
	});
}

function generateHardwareConf(eeprom) {
	return new Promise(function(resolve, reject) {
		write_JSON2file(hardware_conf, eeprom, overwrite_conf, function(err, suc) {
			if (err) {
				console.error("Error Writing file ", hardware_conf, err);
				reject(err);
			} else {
				console.log(suc + ': wrote ' + hardware_conf + ' file successfully');
				resolve();
			}
		});
	});

}

function generateRadioProfileConf(eeprom) {
	return new Promise(function(resolve, reject) {
		var radioConfTemplate = handleBars.compile(JSON.stringify(radioModuleConf));
		var radioData = createHandlebarsDataForRSMI(eeprom);
		var radioConf = JSON.parse(radioConfTemplate(radioData));

		write_JSON2file(rsmi_conf_json_file, radioConf, overwrite_conf, function(err, suc) {
			if (err) {
				console.error("Error Writing file ", rsmi_conf_json_file, err);
				reject(err);
			} else {
				console.log(suc + ': wrote ' + rsmi_conf_json_file + ' file successfully');
				resolve();
			}
		});
	});

}

//main fuction, first determines if we are on purpose based hardware (currently only detects WigWag Relays), or software.   It does this by detecting the EEprom type @ a specific location. 
function main() {
	return new Promise(function(resolve, reject) {

		reader.exists(function(the_eeprom_exists) {
			if (the_eeprom_exists) {
				console.log("Hardware based Relay found.");
				//	if (!exists) {
				get_all(function(result) {
					//this checks if the eeprom had valid data.  I may want to add a different check, perhaps a eeprom_version number, so this file never need to change
					console.log('Read EEPROM- ' + JSON.stringify(result));
					if(typeof result.BRAND === 'undefined') {
						reject(new Error('No relay ID found, please re-configure EEPROM'));
						return;
					}

					if (result.BRAND == "WW" || result.BRAND == "WD") {
						hw = define_hardware(result);
						result.hardware = hw;


						var p = [];

						p.push(writeSecurity());
						p.push(generateDevicejsConf(result));
						p.push(generateRelayConf(result, "wwrelay_v"));
						p.push(generateHardwareConf(result));

						if(radioProfile_template_conf_file) {
							p.push(generateRadioProfileConf(result));
						}

						Promise.all(p).then(function(result) {
							console.log('EEPROM reader successful');
							resolve();
						}, function(err) {
							reject(err);
						});
					}
					else {
						console.log("EEPROM is not configured properly.");
						reject(new Error('EEPROM is not configured properly.'));
						return;
					}
				});
			} else { //eprom doesn't exist... must do other things.  Assume the relay.conf just exists in desired form
				console.log("Software based Relay found");
				softwareBasedRelay = true;

				eeprom2relay(sw_eeprom_file, function(err, result) {
					console.log('Read EEPROM- ' + JSON.stringify(result));
					if(typeof result.BRAND === 'undefined') {
						reject(new Error('No relay ID found, please re-configure EEPROM'));
						return;
					}

					if (result) {
						if (result.BRAND == "WW" || result.BRAND == "WD") {
							hw = define_hardware(result);
							result.hardware = hw;

							var p = [];

							p.push(generateRelayConf(result, "softrelay"));
							p.push(generateHardwareConf(result));

							Promise.all(p).then(function(result) {
								console.log('EEPROM reader successful');
								resolve();
							}, function(err) {
								reject(err);
							});
						}
						else {
							console.log("EEPROM is not configured properly.");
							reject(new Error('EEPROM is not configured properly.'));
						}
					}
				});
			}
		});
	});
}

program
	.version('0.0.1')
	.option('-c, --cloudURL [URL]', 'Specify cloud URL for your relay', 'https://cloud.wigwag.com')
	.option('-o, --overwrite [true/false]', 'overwrite relay.config.json', 'false')
	.option('-O, --overwriteSSL [overwrite|dontoverwrite]', 'overwrite the SSL certificates if they exist', 'dontoverwrite')
	.option('-e, --eepromFile [filepath]', 'For software based relay specify the eeprom json object file path')
	.option('-t, --templateFile [filepath]', 'Specify the template config file')
	.option('-r, --relayConfFile [true/false]', 'Specify the path for relay.config.json for Runner')
	.option('-p, --radioProfiletemplateFile [filepath]', 'Specify the rsmi template config file')
	.option('-s, --rsmiConfFile [filepath]', 'Specify the rsmi radioProfile.config.json for RSMI')
	.option('-b, --cloudDdbURL [url]', 'Specify the cloud database url', 'https://devicedb.wigwag.com')
	.option('-d, --cloudDevicejsURL [url]', 'Specify the cloud devicejs url', 'https://devicejs.wigwag.com')
	.option('-m, --devicejsConfTemplateFile [filepath]', 'Specify the devicejs config template file')
	.option('-n, --devicejsConfFile [filepath]', 'Specify the output devicejs configuration file path')
	.parse(process.argv);

program.on('--help', function() {
	console.log(' Examples:');
	console.log("");
	console.log("  $ node qrLabelMaker.js -t relay <infile> [<outfile>] (No extension. We will add .ps and .csv");
});
if (program.cloudURL) {
	cloudURL = program.cloudURL;
	console.log('Using cloud URL- ', cloudURL);
}

if (program.eepromFile) {
	sw_eeprom_file = program.eepromFile;
	console.log('Using eepromFile- ', sw_eeprom_file);
}

if (program.templateFile) {
	template_conf_file = program.templateFile;
	console.log('Using templateFile- ', template_conf_file);
	try {
		devjsconf = JSON.parse(jsonminify(fs.readFileSync(template_conf_file, 'utf8')));
	}
	catch (e) {
		console.error('Could not open template file', e);
		process.exit(1);
	}

	if (program.relayConfFile) {
		relay_conf_json_file = program.relayConfFile;
		console.log('Using relayConfFile- ', relay_conf_json_file);
	}
	else {
		console.error('Please specify the relay.config.json file path');
		process.exit(1);
	}

	if (program.radioProfiletemplateFile) {
		radioProfile_template_conf_file = program.radioProfiletemplateFile;
		console.log('Using radio profile templateFile- ', radioProfile_template_conf_file);
		try {
			radioModuleConf = JSON.parse(jsonminify(fs.readFileSync(radioProfile_template_conf_file, 'utf8')));
		}
		catch (e) {
			console.error('Could not open radio profile template file', e);
			process.exit(1);
		}

		if (program.rsmiConfFile) {
			rsmi_conf_json_file = program.rsmiConfFile;
			console.log('Using rsmiConfFile- ', rsmi_conf_json_file);
		}
		else {
			console.error('Please specify the radioProfile.config.json file path');
			process.exit(1);
		}
	}
	else {
		console.error('Please specify radio profile template file');
		process.exit(1);
	}
}
else {
	console.error('Please specify relay template file');
	process.exit(1);
}

if (program.overwrite) {
	overwrite_conf = program.overwrite == 'true';
	console.log('Using overwrite- ', overwrite_conf);
}
if (program.overwriteSSL) {
	var POM = program.overwriteSSL;
	console.log('Using overwriteSSL- ', POM);
}

if(program.devicejsConfFile && program.devicejsConfTemplateFile) {
	console.log('Got to generate devicejs conf file for devicejs2.0');
	console.log('Using devicejs conf template- ', program.devicejsConfTemplateFile);
	console.log('Using devicejs conf output file- ', program.devicejsConfFile);
	devicejs_conf_file = program.devicejsConfFile;
	templateDevicejsConf = JSON.parse(jsonminify(fs.readFileSync(program.devicejsConfTemplateFile, 'utf8')));

	if(program.cloudDevicejsURL && program.cloudDdbURL) {
		console.log('Using cloud devicejs url- ' + program.cloudDevicejsURL + ' , using cloud database url- ' + program.cloudDdbURL);
		cloudDevicejsURL = program.cloudDevicejsURL;
		cloudDdbURL = program.cloudDdbURL;
	} else {
		console.error('Please specify urls for cloud database and devicejs');
		process.exit(1);
	}
} else {
	console.warn('Not generating devicejs config file as command line options are not provided');
}

main().then(function() {
	if (!softwareBasedRelay) {
		setupLEDGPIOs().then(function() {
			enableRTC();
		});
	}
}, function(err) {
	console.log('EEPROM reader got error- ' + JSON.stringify(err));
	process.exit(1);
});