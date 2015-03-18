#!/usr/bin/env node

//hints for i2cdump
// ./i2cdump 

var WWAT24 = require('./WWrelay_at24c16.js');
writer = new WWAT24();
var CI = require('./eeprom.json');

var Promise = require('es6-promise').Promise;

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

function rrec(cb) {
	CI.REP1 = CI.relayID.substring(0, 2);
	CI.REP2 = CI.relayID.substring(2, 4);
	CI.REP3 = CI.relayID.substring(4, 10);
	CI.ethernetMAC = decRay2str(CI.ethernetMAC);
	CI.sixBMAC = decRay2str(CI.sixBMAC);

	writer.set("BRAND", CI.REP1).then(function(result) {
		console.log("complete: BRAND with [" + CI.REP1 + "]");
		writer.set("DEVICE", CI.REP2).then(function(result) {
			console.log("complete: DEVICE with [" + CI.REP2 + "]");
			writer.set("UUID", CI.REP3).then(function(result) {
				console.log("complete: UUID with [" + CI.REP3 + "]");
				writer.set("hardwareVersion", CI.hardwareVersion).then(function(result) {
					console.log("complete: hardwareVersion with [" + CI.hardwareVersion + "]");
					writer.set("firmwareVersion", CI.firmwareVersion).then(function(result) {
						console.log("complete: firmwareVersion with [" + CI.firmwareVersion + "]");
						writer.set("radioConfig", CI.radioConfig).then(function(result) {
							console.log("complete: radioConfig with [" + CI.radioConfig + "]");
							writer.set("year", CI.year).then(function(result) {
								console.log("complete: year with [" + CI.year + "]");
								writer.set("month", CI.month).then(function(result) {
									console.log("complete: month with [" + CI.month + "]");
									writer.set("batch", CI.batch).then(function(result) {
										console.log("complete: batch with [" + CI.batch + "]");
										writer.set("ethernetMAC", CI.ethernetMAC).then(function(result) {
											console.log("complete: ethernetMAC with [" + CI.ethernetMAC + "]");
											writer.set("sixBMAC", CI.sixBMAC).then(function(result) {
												console.log("complete: sixBMAC with [" + CI.sixBMAC + "]");
												writer.set("relaySecret", CI.relaySecret).then(function(result) {
													console.log("complete: relaySecret with [" + CI.relaySecret + "]");
													writer.set("pairingCode", CI.pairingCode).then(function(result) {
														console.log("complete: pairingCode with [" + CI.pairingCode + "]");
													});
												});
											});
										});
									});
								});
							});
						});
					});
				});
			});
		});
	});

}

writer.erase(0).then(function(res) {
	console.log("primise full: now lets do it for relasz " + res);
	rrec();
});