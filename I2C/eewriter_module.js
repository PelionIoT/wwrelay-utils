#!/usr/bin/env node

//hints for i2cdump
// ./i2cdump 
var Promise = require('es6-promise').Promise;
var WWAT24 = require('./WWrelay_at24c16.js');
writer = new WWAT24();

function EEprom_Writer(obj) {
	this.CI = obj;
}

function decRay2str(array) {
	var str = ""
	for (var i = 0; i < array.length; i++) {
		var hex = array[i].toString(16);
		var charc = String.fromCharCode(array[i]);
		//	console.log("I belive that %s is '%s' and is '%s' reversed '%s'", array[i], hex, charc, charc.charCodeAt(0));
		str = str + charc;
	};
	return str;
}

function cl(text) {
	//console.log(text);
}

EEprom_Writer.prototype.rrec = function() {
	var self = this;
	return new Promise(function(resolve, reject) {
		self.CI.REP1 = self.CI.relayID.substring(0, 2);
		self.CI.REP2 = self.CI.relayID.substring(2, 4);
		self.CI.REP3 = self.CI.relayID.substring(4, 10);
		self.CI.ethernetMAC = decRay2str(self.CI.ethernetMAC);
		self.CI.sixBMAC = decRay2str(self.CI.sixBMAC);
		writer.set("BRAND", self.CI.REP1).then(function(result) {
			cl("complete: BRAND with [" + self.CI.REP1 + "]");
			writer.set("DEVICE", self.CI.REP2).then(function(result) {
				cl("complete: DEVICE with [" + self.CI.REP2 + "]");
				writer.set("UUID", self.CI.REP3).then(function(result) {
					cl("complete: UUID with [" + self.CI.REP3 + "]");
					writer.set("hardwareVersion", self.CI.hardwareVersion).then(function(result) {
						cl("complete: hardwareVersion with [" + self.CI.hardwareVersion + "]");
						//writer.set("firmwareVersion", self.CI.firmwareVersion).then(function(result) {
						//	cl("complete: firmwareVersion with [" + self.CI.firmwareVersion + "]");
						writer.set("radioConfig", self.CI.radioConfig).then(function(result) {
							cl("complete: radioConfig with [" + self.CI.radioConfig + "]");
							writer.set("year", self.CI.year).then(function(result) {
								cl("complete: year with [" + self.CI.year + "]");
								writer.set("month", self.CI.month).then(function(result) {
									cl("complete: month with [" + self.CI.month + "]");
									writer.set("batch", self.CI.batch).then(function(result) {
										cl("complete: batch with [" + self.CI.batch + "]");
										writer.set("ethernetMAC", self.CI.ethernetMAC).then(function(result) {
											cl("complete: ethernetMAC with [" + self.CI.ethernetMAC + "]");
											writer.set("sixBMAC", self.CI.sixBMAC).then(function(result) {
												cl("complete: sixBMAC with [" + self.CI.sixBMAC + "]");
												writer.set("relaySecret", self.CI.relaySecret).then(function(result) {
													cl("complete: relaySecret with [" + self.CI.relaySecret + "]");
													writer.set("pairingCode", self.CI.pairingCode).then(function(result) {
														cl("complete: pairingCode with [" + self.CI.pairingCode + "]");
														resolve("success");
													});
												});
											});
										});
									});
								});
							});
						});
						//});
					});
				});
			});
		});
	});
}

EEprom_Writer.prototype.write = function() {
	var self = this;
	return new Promise(function(resolve, reject) {
		writer.erase(0).then(function(res) {
			self.rrec().then(function(res) {
				resolve(res);
			});
		});
	});
}

EEprom_Writer.prototype.write_one = function(target, value) {
	var self = this;
	return new Promise(function(resolve, reject) {
		writer.set(target, value).then(function(result) {
			resolve(result);
		}, function(err) {
			reject(err);
		});
	});
}

EEprom_Writer.prototype.erase = function() {
	var self = this;
	return new Promise(function(resolve, reject) {
		writer.erase(0).then(function(res) {
			resolve(res);
		});
	});
}

module.exports = EEprom_Writer;