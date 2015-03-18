#!/usr/bin/env node

var AT24 = require('./at24c16k.js');
at24 = new AT24();

var Promise = require('es6-promise').Promise;
/*-------------------------------------------------------------------------------------------------------------------
The WigWag Relay uses a atmel AT24c16k chip to store 2048 bytes of data.  This chip is orgnized into 256 byte chunks represetned at 8 memory addresses on the i2c-1 bus.	at24c16k.js handles all reading and writing to the i2c bus.  We have orgnaized the chip into 8 spaces organized 0..7.   (We call the 8 addresses spacenum.)  Each spacnum has 0x00 to 0xFF addresses (256) to store 1 Byte per address.  When saving a varrible to the space, (represented by a string of characters saved as 8-byte hex values) we must reference the memory page_address 0|1|2|3|4|5|6|7 where the information is stored, as well as the starting address for the varrible in hex.  Moreover we must provide the length of the varriable in order to properly achive fetching and retrieving.  It is up to the programmer of this file to determine the layout of the eeprom.

e.g. We are saving the 17 character serial number for the relay	in page_address 0, starting at 0x00 with a length of 17.  Thus the start address of the serial number is 0x00 and the end address is 0x00+17=0x11.  Take note of the code below representing the serialnumber.  We cannot save any other information to spacenum=0, between 0x00 and 0x11.  howerver, other varribles can be saved to space num 1,2,3,4,5,6 or 7 in the same address space.  Morever, spacenum=0 has address space 0x12 throughy 0xFF avaiable. 		
--------------------------------------------------------------------------------------------------------------------------------*/
//Serial number memory space
var serial_spacenum = 0;
var serial_start = 0x00;
var serial_length = 0x19; //25 chars 

var sKey_spacenum = 0;
var sKey_start = 0xd0;
var sKey_length = 0x20;
//256 byte key memory space 
var HugeKey_spacenum = 1;
var HugeKey_start = 0x00;
var HugeKey_length = 0xFF;

/*---------------------------------------------SN Convention -------------------------------------------------------

All of this is officaially documented here: https://docs.google.com/a/izuma.net/document/d/1GHjnBHgxvSrQvBbxinYE35r1T4U_gsVYge-ZPvvI-ec/edit#heading=h.mndj5apk7o10
Serial string consists of 17 characters with the following breakdown for character positions. */

//Public 
function WWEEPROM() {
	var self = this;
	this.Layout = {
		"BRAND": {
			"memaddr": "0",
			"len": "2",
			"jname": "REP1"
		},
		"DEVICE": {
			"memaddr": "2",
			"len": "2",
			"jname": "REP2"
		},
		"UUID": {
			"memaddr": "4",
			"len": "6",
			"jname": "REP3"
		},
		"hardwareVersion": {
			"memaddr": "10",
			"len": "5",
			"jname": "hardwareVersion"
		},
		"firmwareVersion": {
			"memaddr": "15",
			"len": "5",
			"jname": "firmwareVersion"
		},
		"radioConfig": {
			"memaddr": "20",
			"len": "2",
			"jname": "radioConfig"
		},
		"year": {
			"memaddr": "22",
			"len": "1",
			"jname": "year"
		},
		"month": {
			"memaddr": "23",
			"len": "1",
			"jname": "month"
		},
		"batch": {
			"memaddr": "24",
			"len": "1",
			"jname": "batch"
		},
		"ethernetMAC": {
			"memaddr": "25",
			"len": "6",
			"jname": "ethernetMAC"
		},
		"sixBMAC": {
			"memaddr": "31",
			"len": "8",
			"jname": "sixBMAC"
		},
		"relaySecret": {
			"memaddr": "39",
			"len": "32",
			"jname": "relaySecret"
		},
		"pairingCode": {
			"memaddr": "71",
			"len": "25",
			"jname": "pairingCode"
		}
	}

}

setText = function(spacenum, start, text, callback) {
	//console.log("settext %s, %s, %s", spacenum, start, text);
	at24.writeout(spacenum, start, text.split(""), function(err, suc) {
		if (err) {
			callback(err, null);
		}
		else {
			callback(null, suc);
		}
	});
}

/*-------------------------------------------------------------------------------------------------------------------
SERIAL
-------------------------------------------------------------------------------------------------------------------*/

WWEEPROM.prototype.set = function(key, value) {
	var self = this;
	//console.log("set %s %s %d", key, value, 5);
	return new Promise(function(resolve, reject) {
		lookup = eval("self.Layout." + key);
		if (lookup.len == value.length) {
			//console.log("calling setText");
			setText(serial_spacenum, lookup.memaddr, value, function(err, success) {
				if (err) reject(Error(err));
				else resolve(success);
			});
		}
		else reject(Eror("Length mismatch, provided %s != %s", value.length, lookup.len));
	});
}

WWEEPROM.prototype.erase = function(page, callback) {
	return new Promise(function(resolve, reject) {
		setText(page, 0, "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------",
			function(err, success) {
				if (err) reject(Error(err));
				else resolve(success);
			});
	});

}

WWEEPROM.prototype.get = function(key) {
	var self = this;
	return new Promise(function(resolve, reject) {
		lookup = eval("self.Layout." + key);
		var totalchars = (+lookup.memaddr + +lookup.len);
		//console.log("reading from: 0x%s number of chars %s, for final memaddress of %s", parseInt(lookup.memaddr, 10).toString(16), lookup.len, parseInt(totalchars, 10).toString(16));
		at24.readout(serial_spacenum, lookup.memaddr, totalchars, function(err, success) {
			if (err) reject(Error(err));
			else resolve(success);
		});

	});
}

WWEEPROM.prototype.readSpecial = function() {
	var self = this;
	at24.readout(serial_spacenum, 0x1A, 0x1B, function(a, b) {
		if (b instanceof Buffer) {
			console.log("its a buffer");
			//console.log("length %s, b %s", b.length, b.toString('ascii').charCodeAt());
			console.log("length %s, b %s", b.length, b.readUInt8(0));
		}

	});
}

module.exports = WWEEPROM;