#!/usr/bin/env node

//hints for i2cdump
// ./i2cdump
var Promise = require('es6-promise').Promise;
var WWAT24 = require('./WWrelay_at24c16.js');
var DiskStorage = require("./diskstore.js");
var diskprom = new DiskStorage("/dev/mmcblk0p1", "/mnt/.boot/", ".ssl");
var ssl_client_key = "client.key.pem";
var ssl_client_cert = "client.cert.pem";
var ssl_server_key = "server.key.pem";
var ssl_server_cert = "server.cert.pem";
var ssl_ca_cert = "ca.cert.pem";
var ssl_ca_intermediate = "intermediate.cert.pem";

writer = new WWAT24();

function EEprom_Writer(obj) {
	this.CI = obj;
}

function decRay2str(array) {
	var str = "";
	for (var i = 0; i < array.length; i++) {
		var hex = array[i].toString(16);
		var charc = String.fromCharCode(array[i]);
		//	console.log("I belive that %s is '%s' and is '%s' reversed '%s'", array[i], hex, charc, charc.charCodeAt(0));
		str = str + charc;
	}
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
		self.CI.ethernetMAC_og = self.CI.ethernetMAC;
		self.CI.sixBMAC_og = self.CI.sixBMAC;
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
														if (self.CI.ledConfig === null || self.CI.ledConfig === undefined) {
															self.CI.ledConfig = "01";
														}
														writer.set("ledConfig", self.CI.ledConfig).then(function(result) {
															cl("complete: ledConfig with [" + self.CI.ledConfig + "]");
															resolve("success");
														});
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
};

EEprom_Writer.prototype.recordCloudUrl = function() {
	var self = this;
	return new Promise(function(resolve, reject) {
		self.CI.cloudURL = self.CI.cloudURL || "https://cloud.wigwag.com";
		self.CI.devicejsCloudURL = self.CI.devicejsCloudURL || "https://devicejs.wigwag.com";
		self.CI.devicedbCloudURL = self.CI.devicedbCloudURL || "https://devicedb.wigwag.com";

		writer.set("cloudURL", self.CI.cloudURL).then(function(result) {
			
		})
	});
};

EEprom_Writer.prototype.writeEMMC = function() {
	var self = this;
	return new Promise(function(resolve, reject) {
		writer.erase(0).then(function(res) {
			console.log("recording to EEPROM ");
			Pcert = [];
			Pcert.push(self.rrec());
			Pcert.push(self.recordCloudUrl());
			Promise.all(Pcert).then(function(result) {
				resolve("successfull eeprom writer");
			}).catch(function(error) {
				console.log("debug", "EEprom_Writer.prototype.writeEMMC.Pcert errored: " + error);
				reject("EEprom_Writer.prototype.writeEMMC.Pcert errored:" + error);
			});
		});
	});
};

EEprom_Writer.prototype.writeSSL = function() {
	var self = this;
	return new Promise(function(resolve, reject) {
		console.log("Writing to SSL diskprom");
		console.log(JSON.stringify(self.CI));
		Pcert = [];
		Pcert.push(diskprom.setFile(ssl_server_cert, self.CI.ssl.server.certificate));
		Pcert.push(diskprom.setFile(ssl_client_cert, self.CI.ssl.client.certificate));
		Pcert.push(diskprom.setFile(ssl_server_key, self.CI.ssl.server.key));
		Pcert.push(diskprom.setFile(ssl_client_key, self.CI.ssl.client.key));
		Pcert.push(diskprom.setFile(ssl_ca_cert, self.CI.ssl.ca.ca));
		Pcert.push(diskprom.setFile(ssl_ca_intermediate, self.CI.ssl.ca.intermediate));
		Promise.all(Pcert).then(function(result) {
			return diskprom.disconnect();
		}).then(function(result) {
			resolve("successfull diskprom writer");
		}).catch(function(error) {
			console.log("debug", "EEprom_Writer.prototype.writeSSL.Pcert errored: " + error);
			reject("EEprom_Writer.prototype.writeSSL.Pcert errored:" + error);
		});

	});
};

EEprom_Writer.prototype.destroySSL = function() {
	var self = this;
	return new Promise(function(resolve, reject) {
		console.log("Destroying  SSL diskprom");
		//console.log(JSON.stringify(self.CI));
		Pcert = [];
		Pcert.push(diskprom.destroyFile(ssl_server_cert));
		Pcert.push(diskprom.destroyFile(ssl_client_cert));
		Pcert.push(diskprom.destroyFile(ssl_server_key));
		Pcert.push(diskprom.destroyFile(ssl_client_key));
		Pcert.push(diskprom.destroyFile(ssl_ca_cert));
		Pcert.push(diskprom.destroyFile(ssl_ca_intermediate));
		Promise.all(Pcert).then(function(result) {
			resolve("successfull diskprom destroyer");
		}).catch(function(error) {
			console.log("debug", "EEprom_Writer.prototype.destroySSL.Pcert errored: " + error);
			reject("EEprom_Writer.prototype.writeSSL.Pcert errored:" + error);
		});

	});
};

EEprom_Writer.prototype.writeBoth = function() {
	var self = this;
	return new Promise(function(resolve, reject) {
		console.log("recording to EEPROM and to to disk for ssl");
		Pcert = [];
		Pcert.push(self.rrec());
		Pcert.push(diskprom.setFile(ssl_server_cert, self.CI.ssl.server.certificate));
		Pcert.push(diskprom.setFile(ssl_client_cert, self.CI.ssl.client.certificate));
		Pcert.push(diskprom.setFile(ssl_server_key, self.CI.ssl.server.key));
		Pcert.push(diskprom.setFile(ssl_client_key, self.CI.ssl.client.key));
		Pcert.push(diskprom.setFile(ssl_ca_cert, self.CI.ssl.ca.ca));
		Pcert.push(diskprom.setFile(ssl_ca_intermediate, self.CI.ssl.ca.intermediate));
		Promise.all(Pcert).then(function(result) {
			resolve("successfull eeprom writer");
		}).catch(function(error) {
			console.log("debug", "EEprom_Writer.prototype.write.Pcert errored: " + error);
			reject("EEprom_Writer.prototype.write.Pcert errored:" + error);
		});
	});
};

EEprom_Writer.prototype.erase = function() {
	var self = this;
	console.log("calling the rease");
	Perase = [];
	Perase.push(self.destroySSL());
	Perase.push(writer.erase(0));
	return Promise.all(Perase);
};

EEprom_Writer.prototype.eraseSSL = function() {
	var self = this;
	console.log("calling the rease");
	Perase = [];
	Perase.push(self.destroySSL());
	//Perase.push(writer.erase(0));
	return Promise.all(Perase);
};

EEprom_Writer.prototype.eraseEEPROM = function() {
	var self = this;
	console.log("calling the rease");
	Perase = [];
	//Perase.push(self.destroySSL());
	Perase.push(writer.erase(0));
	return Promise.all(Perase);
};

module.exports = EEprom_Writer;