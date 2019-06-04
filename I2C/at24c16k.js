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


//handy links: http://docs.cubieboard.org/tutorials/cb1/development/access_at24c_eeprom_via_i2c

//Private Varriables
var i2c = require('i2c');
var space_addresses = new Array(0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57);
var deviceName = '/dev/i2c-1';
ATqueue = [];
ATworking = false;

baseaddress = function(x) {
	switch (true) {
		case x <= 0xF:
			return 0x00;
			break;
		case x <= 0x1F:
			return 0x10;
			break;
		case x <= 0x2F:
			return 0x20;
			break;
		case x <= 0x3F:
			return 0x30;
			break;
		case x <= 0x4F:
			return 0x40;
			break;
		case x <= 0x5F:
			return 0x50;
			break;
		case x <= 0x6F:
			return 0x60;
			break;
		case x <= 0x7F:
			return 0x70;
			break;
		case x <= 0x8F:
			return 0x80;
			break;
		case x <= 0x9F:
			return 0x90;
			break;
		case x <= 0xAF:
			return 0xA0;
			break;
		case x <= 0xBF:
			return 0xB0;
			break;
		case x <= 0xCF:
			return 0xC0;
			break;
		case x <= 0xDF:
			return 0xD0;
			break;
		case x <= 0xEF:
			return 0xE0;
			break;
		case x <= 0xFF:
			return 0xF0;
			break;
	}
};

//Public
function AT24C16() {
	var self = this;
	this.spaces = [];
	space_addresses.forEach(function(address) {
		temp = new i2c(address, {
			device: deviceName
		});
		self.spaces.push(temp);
	});
	this.memspace_size = 256; //bytes
	this.memspaces = 8;
	this.maxlength = this.memspace_size * this.memspaces;

}

/*------------------------------------------------------------------------------------------------------------------
WRITE
-------------------------------------------------------------------------------------------------------------------*/
AT24C16.prototype.writeout = function(spacenumber, from, Ray, callback) {
	var self = this;
	var base = baseaddress(from);
	var topp = base + 0xF;
	var ccells = topp - from + 1;
	var newRay = Ray.splice(0, ccells).map(function(val) {
		return "0x" + val.charCodeAt(0).toString(16);
	});
	console.log('spacenumber ' + spacenumber + ' from ' + from + ' newRay ' + newRay);
	self.spaces[spacenumber].writeBytes(from, newRay, function(err) {
		if (err) {
			callback(err, null);
		}
		else {
			if (Ray.length > 0) {
				setTimeout(function() {
					self.writeout(spacenumber, topp + 0x01, Ray, callback);
				}, 35);
			}
			else {

				setTimeout(function() {
					callback(null, "success");
				}, 100);
				//callback(null, "success");
			}
		}
	});
};

/*------------------------------------------------------------------------------------------------------------------
ERASE
-------------------------------------------------------------------------------------------------------------------*/
AT24C16.prototype.erase = function(spacenumber, from, Ray, callback) {
	var self = this;
	var base = baseaddress(from);
	var topp = base + 0xF;
	var ccells = topp - from + 1;
	var temp = Ray.splice(0, ccells);
	var newRay = new Array(ccells);
	newRay.fill('0xFF');
	self.spaces[spacenumber].writeBytes(from, newRay, function(err) {
		if (err) {
			callback(err, null);
		}
		else {
			if (Ray.length > 0) {
				setTimeout(function() {
					self.erase(spacenumber, topp + 0x01, Ray, callback);
				}, 35);
			}
			else {
				setTimeout(function() {
					callback(null, "success");
				}, 100);
				//callback(null, "success");
			}
		}
	});
};

/*------------------------------------------------------------------------------------------------------------------
READ
-------------------------------------------------------------------------------------------------------------------*/
AT24C16.prototype.readout = function(spacenumber, from, end, callback) {
	var self = this;
	var lastresn = "";
	end = end || 256;
	var diff = (+end - +from);
	var done = false;
	var spliton = 30;
	if (diff > spliton) {
		newlen = spliton;
		var nextfrom = (+from + spliton);
	}
	else {
		newlen = diff;
		done = true;
	} //have to read in 31 at a time.
	//console.log("splitting on %d, the diff %d, nextfrom: %d, end %d from %d newlen %d", spliton, diff, nextfrom, end, from, newlen);
	self.spaces[spacenumber].readBytes(from, newlen, function(err, res) {
		var nextlen = end;
		var currentlen = newlen;
		var nextfrom2 = nextfrom;
		var amdone = done;
		//console.log("down here: nextlen %d, currentlen %d, nextfrom2 %d", nextlen, currentlen, nextfrom2);
		if (typeof self.lastres != 'undefined') self.lastres = self.lastres + res;
		else self.lastres = res;
		if (!err) {
			if (!amdone) {
				self.readout(spacenumber, nextfrom2, nextlen, callback);
			}
			else {
				callback(false, self.lastres);
				self.lastres = undefined;
			}
		}
		else {
			callback(err, null);
			self.lastres = undefined;
		}
	});
};

AT24C16.prototype.exists = function(callback) {
	var self = this;
	try {
		var wire = new i2c(0x50, {
			device: '/dev/i2c-1'
		});

		wire.scan(function(err, success) {
			if (err) callback(false);
			if (success) {
				if (success.length == 8 && success[0] == 80 && success[7] == 87) {
					callback(true);
				}
				else callback(false);
			}

		});
	}
	catch (err) {
		callback(false);
	}
};

AT24C16.prototype.factory_written = function(callback) {
	var self = this;
	try {
		var wire = new i2c(0x50, {
			device: '/dev/i2c-1'
		});

		wire.scan(function(err, success) {
			if (err) callback(false);
			if (success) {
				if (success.length == 8 && success[0] == 80 && success[7] == 87) {
					callback(true);
				}
				else callback(false);
			}

		});
	}
	catch (err) {
		callback(false);
	}
};

module.exports = AT24C16;
// console.log("did you get your data");