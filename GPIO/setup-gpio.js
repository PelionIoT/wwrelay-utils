#!/usr/bin/env node
 //Replaces the old setup-gpio.sh script

//r/w files
var fs = require('fs');

var exec = require('child_process').exec;
//var execSync = require('child_process').execSync;
//var execSync = require('execSync');

//var path = require('path');
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

function set_direction(callback) {
	var dir = "out";
	var completed = 3;
	var total = config.hardware.gpioProfile.NumberOfOutputs + config.hardware.gpioProfile.NumberOfInputs;
	var fileray = fs.readdirSync("/sys/class/gpio/");
	var re = /(gpio)(\d+)(.+)/i;
	for (var i = 0; i < fileray.length; i++) {
		if (fileray[i] != "export" && fileray[i] != "unexport" && fileray[i] != "gpiochip1") {
			var caught = fileray[i].match(re)[2];
			if (caught > config.hardware.gpioProfile.NumberOfOutputs) dir = "in"
			else dir = "out";
			fullpath = gpio_path + fileray[i] + "/direction";
			fs.writeFile(fullpath, dir, function(err, success) {
				if (err) {
					callback("total failure", null);
				}
				else {
					completed++;
					if (completed >= fileray.length) {
						callback(null, "success");
					}
				}
			});
		}
	}
}

function exportGPIO(type, callback) {
	var complete = 0;
	var total = config.hardware.gpioProfile.NumberOfOutputs + config.hardware.gpioProfile.NumberOfInputs;
	if (type == 1) var file = exportpath;
	else if (type == 0) var file = unexportpath;
	else callback("type not defined", null);
	fs.open(file, "w", 0666, function(err, fd) {
		if (err) console.log("Error opening " + file);
		else {
			for (var i = 1; i <= total; i++) {
				fs.write(fd, i, null, null, function(err, written, string) {
					complete++;
					//	console.log("complete (%s) of (%s)", complete, total);
					if (err) console.log("Error writting to export");
					if (complete == total) callback(null, "success");
				});
			}
		}
	});
}

function fix_red(callback) {
	success = "Sucessfully set the red as desired";
	failure = "failed to set the red as desired";
	fs.writeFile(config.hardware.gpioProfile.TopRed + "/brightness", 1, function(err, data) {
		if (err) {
			console.log("Could not enable a normal red led");
			callback(failure, null);
		}
		else {
			fs.writeFile(config.hardware.gpioProfile.RED_OFF + "/value", 1, function(err, data) {
				if (err) {
					console.log("Could not disable the red boot flag for the Top LED");
					callback(failure, null);
				}
				else {
					callback(null, success);
				}
			});
		}
	});
}

function main() {
	read_config(function(err, suc) {
		console.log("startin main");
		if (err) {
			console.log("err reading config: %s", err);
		}

		else {
			exportGPIO(1, function(err, success) {
				if (err) {
					console.log("Error published: %s", err);
				}
				if (success) {
					set_direction(function(err, success) {
						if (err) {
							console.log("Error now: %s", err);
							fix_red(function(err, success) {
								if (err) {
									console.log("Error: %s", err);
								}
								if (success) {
									console.log("Success: %s", success);
								}
							});
						}
						if (success) {
							fix_red(function(err, success) {
								if (err) {
									console.log("Error: %s", err);
								}
								if (success) {
									console.log("Success: %s", success);
								}
							});
						}
					});
				}
			});
		}
	});
}
main();

//reader.readSpecial();