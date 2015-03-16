#!/usr/bin/env node

var WWAT24 = require('./WWrelay_at24c16.js');
reader=new WWAT24();

//r/w files
var fs = require('fs');

var path = require('path'); 

var file="/etc/wigwag/relay.conf";
var filestring="{\"relayID\":\"RELAYID\",\"relaySecret\":\"RELAYSECRET\",\"cloudURL\":\"https://cloud.wigwag.com\",\"HWVersion\":\"HARDWAREVERSION\",\"RadioCFG\":\"RADIOCONFIG\",\"qrcode\":\"QRCODE\"}";





function display_sn_parts(res,cb){
	var BRAND=reader.getSNpart("BRAND",res); 
	var DEVICE=reader.getSNpart("DEVICE",res); 
	var HWVERSION=reader.getSNpart("HWVERSION",res);
	var UUID=reader.getSNpart("UUID",res);
	var RADIO_CONFIG=reader.getSNpart("RADIO_CONFIG", res);
	var MFG_YEAR=reader.getSNpart("MFG_YEAR",res);
	var MFG_MONTH=reader.getSNpart("MFG_MONTH", res);
	var MFG_BATCH=reader.getSNpart("MFG_BATCH",res);
	console.log("Serial\t\t\%s",res);
	console.log("BRAND\t\t%s",BRAND);
	console.log("DEVICE\t\t%s",DEVICE);
	console.log("HWVERSION\t%s",HWVERSION);
	console.log("UUID\t\t%s",UUID);
	console.log("RADIO_CONFIG\t%s",RADIO_CONFIG);
	console.log("MFG_YEAR\t%s",MFG_YEAR);
	console.log("MFG_MONTH\t%s",MFG_MONTH);
	console.log("MFG_BATCH\t%s",MFG_BATCH);
	cb();
}

function display_HugeKey_parts(res,cb){
	var HugeKey=res.toString();
	console.log("HugeKey\t%s\n",HugeKey);
	cb();
}

function replace(target,string,cb){
	var regex = new RegExp(target,"g");
	filestring=filestring.replace(regex,string);
	if (cb) cb();
}


function display_sKey_parts(res,cb){
	var sKey=res.toString();
	console.log("sKey\t%s\n",sKey);
	cb();
}



function prep_serial(cb) {
	reader.readSerial(function(err,res){
		if(err) { 
			console.log("Found error reading serial:"+err);
			cb();
		}
		else {
			var BRAND=reader.getSNpart("BRAND",res); 
			var DEVICE=reader.getSNpart("DEVICE",res); 
			var UUID=reader.getSNpart("UUID",res);
			replace("RELAYID",BRAND+DEVICE+UUID);
			var HWVERSION=reader.getSNpart("HWVERSION",res); 
			var RADIO_CONFIG=reader.getSNpart("RADIO_CONFIG", res);
			var QRCODE=reader.getSNpart("QRCODE",res);
			replace("HARDWAREVERSION",HWVERSION);
			replace("RADIOCONFIG",RADIO_CONFIG);
			replace("QRCODE",QRCODE,cb);
//display_sn_parts(res,cb);
}
});
}


function rHK() {
	reader.readHugeKey(function(err,res){
		if(err) console.log("FOUND my error here "+err);
		else display_HugeKey_parts(res);
	});
}

function prep_Key(cb) {
	reader.readsKey(function(err,res){
		if(err) {
			console.log("FOUND my error skey here "+err);
			cb();
		}
		else {
			replace("RELAYSECRET",res,cb);
//display_sKey_parts(res,cb);
}
});
}

function write_file(cb) {
	fs.writeFile(file, filestring+"\n", 'utf8', function (err) {
		if (err) {
			return console.log(err);
			cb(err);
		}
		else {
			console.log("Wrote %s",file);
			cb("SUCCESS");
		}
	});
}


function main(){
	fs.exists(file, function(exists) { 
		if (!exists) { 
			prep_serial(function(){
				prep_Key(function(){
					write_file(function(){
						null;
					});
				});
			});
		}
		else {
			console.log("%s arleady exits.",file);
		} 
	}); 
}

main();





