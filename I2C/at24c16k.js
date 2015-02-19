#!/usr/bin/env node

//handy links: http://docs.cubieboard.org/tutorials/cb1/development/access_at24c_eeprom_via_i2c

//Private Varriables
var i2c = require('i2c');
var space_addresses = new Array(0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57);
var deviceName = '/dev/i2c-1';
ATqueue = new Array();
ATworking=false;

baseaddress=function(x){
	switch (true) {
		case x <= 0xF: return 0x00; break;
		case x <= 0x1F: return 0x10; break;
		case x <= 0x2F: return 0x20; break;
		case x <= 0x3F: return 0x30; break;
		case x <= 0x4F: return 0x40; break;
		case x <= 0x5F: return 0x50; break;
		case x <= 0x6F: return 0x60; break;
		case x <= 0x7F: return 0x70; break;
		case x <= 0x8F: return 0x80; break;
		case x <= 0x9F: return 0x90; break;
		case x <= 0xAF: return 0xA0; break;
		case x <= 0xBF: return 0xB0; break;
		case x <= 0xCF: return 0xC0; break;
		case x <= 0xDF: return 0xD0; break;
		case x <= 0xEF: return 0xE0; break;
		case x <= 0xFF: return 0xF0; break;	
	}
}


//Public 
function AT24C16(){
	var self = this;
	this.spaces = new Array();
	space_addresses.forEach(function(address) {
		temp = new i2c(address,{device: deviceName});
		self.spaces.push(temp);
	});
this.memspace_size=256; //bytes 
this.memspaces=8;
this.maxlength = this.memspace_size * this.memspaces;

}

/*------------------------------------------------------------------------------------------------------------------
WRITE
-------------------------------------------------------------------------------------------------------------------*/
AT24C16.prototype.writeout=function(spacenumber,from,Ray,callback){
	var self=this;
	self.base=baseaddress(from);
	self.topp=self.base+0xF;
	self.ccells=self.topp-from+1;
	var newRay=Ray.splice(0,self.ccells).map(function(val){ 
		return "0x"+val.charCodeAt(0).toString(16);
		});
	self.spaces[spacenumber].writeBytes(from,newRay,function(err) {
		if (err) {
		   	callback(err,null);
		}
		else {
			if (Ray.length>0) {
				setTimeout(function(){self.writeout(spacenumber,self.topp+0x01,Ray,callback)},20);	
			}
			else {
				callback(null,"success");
			}
		}
	});
}

/*------------------------------------------------------------------------------------------------------------------
READ
-------------------------------------------------------------------------------------------------------------------*/
AT24C16.prototype.readout=function(spacenumber,from,end,callback){
	var self=this;
	var lastresn="";
	if (end-from>31) { newlen=31; var nextfrom=from+31; }
	else newlen=end-from; //have to read in 31 at a time.
	self.spaces[spacenumber].readBytes(from,newlen,function(err, res) {
		var nextlen=end;
		var currentlen=newlen;
		var nextfrom2=nextfrom;
		if (typeof self.lastres != 'undefined' ) self.lastres=self.lastres+res;
		else self.lastres=res;
		if (!err) { 
			if (currentlen==31) {
				setTimeout(function(){self.readout(spacenumber,nextfrom2,nextlen,callback)},0);
			}
			else {	
				callback(false, self.lastres); 
				self.lastres=undefined;
			}
		}
		else {
			callback(err,null);
			self.lastres=undefined;
		}
	});
}







module.exports = AT24C16;
// console.log("did you get your data");

