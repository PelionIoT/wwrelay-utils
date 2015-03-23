#!/usr/bin/env node

var WWAT24 = require('./WWrelay_at24c16.js');
reader = new WWAT24();

//r/w files
var fs = require('fs');

//travis
var path = require('path');

var file = "/etc/wigwag/relay.conf";

function read(ray, str, callback) {
	var key = ray.shift();
	//console.log("read(%s %s) and the key: %s", key, str, key);
	reader.get(key).then(function(res) {
		var ray2 = ray;
		var str2 = str;
		if (res) {
			str2 += "\"" + key + "\":";
			if (key == "ethernetMAC" || key == "sixBMAC") {
				newray = [];
				for (var i = 0; i < res.length; i++) {
					newray.push(res.readUInt8(i));
				};
				str2 += "[" + newray + "]"
			}
			else {
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

function get_all(callback) {
	str = "{";
	first = true;
	var temp = [];
	for (var attr in reader.Layout) {
		temp.push(attr);
	}
	var res;
	read(temp, str, function(done) {
		var res = JSON.parse(done);
		res.relayID = res.BRAND + res.DEVICE + res.UUID;
		res.cloudURL = "https://cloud.wigwag.com";
		callback(res);
	});
}

function write_file(txt, cb) {
	fs.writeFile(file, JSON.stringify(txt) + "\n", 'utf8', function(err) {
		if (err) {
			cb(err, null);
		}
		else {
			cb(null, "SUCCESS");
		}
	});
}

function main() {
		fs.exists(file, function(exists) {
			if (!exists) {
				get_all(function(result) {
					write_file(result, function(err, suc) {
						if (err) console.log("Error Writing file %s", err);
					});
				});
			}
			else {
				console.log("%s arleady exits.", file);
			}
		});
	}
	//get_one();

main();

//reader.readSpecial();