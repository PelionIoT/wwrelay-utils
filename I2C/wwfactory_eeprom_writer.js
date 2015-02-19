#!/usr/bin/env node

var WWAT24 = require('./WWrelay_at24c16.js');
writer=new WWAT24();

var text = require('./eeprom.json');
//console.log(text.SN+text.HARDWARE+text.RADIO_CONFIG+text.MFG_YEAR+text.MFG_MONTH+text.MFG_BATCH);
//console.log(text.KEY);

function write_sn(cb){
writer.setSerial(text.SN+text.HARDWARE+text.RADIO_CONFIG+text.MFG_YEAR+text.MFG_MONTH+text.MFG_BATCH+text.QR,function(err,suc) {
	if (err) {
		console.log("Writing SN Error: "+err);
		cb();
	}
	else {
		console.log("Success writing SN: "+suc);
		cb();
	}
});
}

function write_sk(cb){
	writer.setsKey(text.KEY,function(err, suc)  {
		if (err) {
			console.log("Write SK Error:"+err);
			cb();
		}
		else {
			console.log("Success writting SK: "+suc);
			cb();
		}
	});
}

write_sn(function(){ 
	write_sk(function(){});
});
