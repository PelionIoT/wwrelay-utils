#!/usr/bin/env node
/*
 * Copyright (c) 2018, Arm Limited and affiliates.
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

 //Replaces the old setup-gpio.sh script

//r/w files
var fs = require('fs');
var exec = require('child_process').exec;
var Promise = require('es6-promise').Promise;
var gpio_path = "/sys/class/gpio/";
var relay_dot_conf = "/etc/wigwag/relay.conf";
var exportpath = "/sys/class/gpio/export";
var unexportpath = "/sys/class/gpio/unexport";

var config = "";

function read_config(callback) {
	fs.readFile(relay_dot_conf, 'ascii', function(err, data) {
		if (err) {
			console.log("error reading " + relay_dot_conf);
			callback(err, null);
		}
		if (data) {
			config = JSON.parse(data);
			callback(null, config);
		}
	});
}
//trav

function set_pin_direction(pindata) {
	//console.log("called with " + pindata.writevalue);
	return new Promise(function(resolve, reject) {
		var fullpath = gpio_path + "gpio" + pindata.writevalue + "/direction";
		//	console.log("set_pin_direction: " + fullpath + " " + pindata.extradata);
		writefile(fullpath, pindata.extradata, pindata.writevalue).then(function(returndirection) {
			//	console.log("direction set " + returndirection.writevalue + " " + returndirection.extradata);
			resolve("direction_set");
		});
	});
}

function writefile(file, value, extra) {
	return new Promise(function(resolve, reject) {
		//console.log("write simple called " + file + " " + value);
		fs.writeFile(file, value, function(error) {
			if (error) {
				//console.log("simple write (" + file + ") " + value + " " + error);
				reject(error + "" + value);
			}
			else {
				//	console.log("simple write success " + value);
				resolve({
					"writevalue": value,
					"extradata": extra
				});
			}
		});
	});
}

function GPIOsetup(type) {
	return new Promise(function(resolve, reject) {
		if (type == "export") {
			var file = exportpath;
		}
		else if (type == "unexport") {
			var file = unexportpath;
		}
		else {
			reject("type not defined");
		}
		//	console.log("file " + file);
		GPIOsetupRay = new Array();
		for (var i in config.hardware.gpioProfile.pins) {
			var pinID = config.hardware.gpioProfile.pins[i].num;
			var pinDIR = config.hardware.gpioProfile.pins[i].direction;
			//	console.log(pinID + " " + file + " " + pinDIR);
			GPIOsetupRay.push(new Promise(function(resolve, reject) {
				writefile(file, pinID, pinDIR).then(function(returnpin) {
					set_pin_direction(returnpin).then(function(success) {
						resolve("pin complete");
					}, function(rej) {
						reject(rej);
					});
				}, function(reej) {
					reject(reej);

				});

			}));
		}
		Promise.all(GPIOsetupRay).then(function(succ) {
			resolve("pins setup");
		}, function(error) {
			reject(error);
		});
	});
}

//valid colors white magenta
function LEDindicator(color) {
	return new Promise(function(resolve, reject) {
		success = "Successfully set the LED to " + color;
		failure = "Failed to set the LED to " + color;
		if (color != "white" && color != "magenta") {
			reject("Not a valid color");
		}
		TR = "/sys/class/leds/red/brightness"
		TB = "/sys/class/leds/blue/brightness"
		TG = "/sys/class/leds/green/brightness"
		OR = ""
		if (config.hardware.gpioProfile.RED_OFF != "") OR = config.hardware.gpioProfile.RED_OFF + "/value";
		if (config.hardware.gpioProfile.TopRed != "") TR = config.hardware.gpioProfile.TopRed + "/brightness";
		if (config.hardware.gpioProfile.TopGreen != "") TG = config.hardware.gpioProfile.TopGreen + "/brightness";
		if (config.hardware.gpioProfile.TopBlue != "") TB = config.hardware.gpioProfile.TopBlue + "/brightness";
		Pray = new Array();
		Pray.push(writefile(TB, 1, "back"));
		Pray.push(writefile(TG, 1, "back"));
		if (color == "magenta" && OR != "") {
			Pray.push(writefile(TR, 1, "back"));
			Pray.push(writefile(OR, 1, "back"));
		}
		Promise.all(Pray).then(function(succ) {
			resolve("color changed " + color);
		}, function(err) {
			reject("color failed " + color);
		});

	});
}

function main() {
	console.log("Starting to setup GPIO's ");
	read_config(function(err, suc) {
		if (err) {
			console.log("err reading config: %s", err);
			LEDindicator("white").then(function(res) {
				console.log("led set to white");
			});
		}
		else {
			temp = new Promise(function(resolve, reject) {
				GPIOsetup("export").then(function(sucesses) {
					console.log("successfully setup all gpios");
					resolve("good");
				}, function(failure) {
					console.log("failed at setting up all gpios: " + failure);
					reject("bad");
				});
			});
			temp.then(function(good) {
				LEDindicator("magenta").then(function(res) {
					console.log("led set to magenta");
				});
			}, function(bad) {
				LEDindicator("white").then(function(res) {
					console.log("led set to white");
				});
			});

		}

	});
}

main();

//setTimeout(function() {}, 500); //reader.readSpecial();