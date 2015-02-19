#!/usr/bin/env node

var AT24 = require('./at24c16k.js');
at24=new AT24();
/*-------------------------------------------------------------------------------------------------------------------
The WigWag Relay uses a atmel AT24c16k chip to store 2048 bytes of data.  This chip is orgnized into 256 byte chunks represetned at 8 memory addresses on the i2c-1 bus.	at24c16k.js handles all reading and writing to the i2c bus.  We have orgnaized the chip into 8 spaces organized 0..7.   (We call the 8 addresses spacenum.)  Each spacnum has 0x00 to 0xFF addresses (256) to store 1 Byte per address.  When saving a varrible to the space, (represented by a string of characters saved as 8-byte hex values) we must reference the memory page_address 0|1|2|3|4|5|6|7 where the information is stored, as well as the starting address for the varrible in hex.  Moreover we must provide the length of the varriable in order to properly achive fetching and retrieving.  It is up to the programmer of this file to determine the layout of the eeprom.

e.g. We are saving the 17 character serial number for the relay	in page_address 0, starting at 0x00 with a length of 17.  Thus the start address of the serial number is 0x00 and the end address is 0x00+17=0x11.  Take note of the code below representing the serialnumber.  We cannot save any other information to spacenum=0, between 0x00 and 0x11.  howerver, other varribles can be saved to space num 1,2,3,4,5,6 or 7 in the same address space.  Morever, spacenum=0 has address space 0x12 throughy 0xFF avaiable. 		
--------------------------------------------------------------------------------------------------------------------------------*/
//Serial number memory space
var serial_spacenum=0;
var serial_start=0x00;
var serial_length=0x19;  //25 chars 

var sKey_spacenum=0;
var sKey_start=0xd0;
var sKey_length=0x20;
//256 byte key memory space 
var HugeKey_spacenum=1;
var HugeKey_start=0x00;
var HugeKey_length=0xFF;


/*---------------------------------------------SN Convention -------------------------------------------------------

All of this is officaially documented here: https://docs.google.com/a/izuma.net/document/d/1GHjnBHgxvSrQvBbxinYE35r1T4U_gsVYge-ZPvvI-ec/edit#heading=h.mndj5apk7o10

Serial string consists of 17 characters with the following breakdown for character positions. */


/*	BRAND: (2 char: 0,1) Whose brand does it fall under
		WW: WigWag
		MP: Monoprice  */
var BRAND_start=0;
var BRAND_length=2;

/*	DEVICE (2 char 2,3)
		RL: Relay
		FL: Filament
		SB: Sensor Block */
var DEVICE_start=2;
var DEVICE_length=2;

/*	UUID (6 char 4-9)
		RANDOM8: Random unique 8 char	*/
var UUID_start=4;
var UUID_length=6;

/*	HWVERSION (2 char 10,11)
		04: relay_lite_v4	*/
var HWVERSION_start=10;
var HWVERSION_length=2;

/*	RADIO_CONFIG (2 char 12,13)
		01: 6BMC13224	*/
var RADIO_CONFIG_start=12;
var RADIO_CONFIG_length=2;

/*	MFG_YEAR (1 char, 14)
		5: 2015	*/
var MFG_YEAR_start=14;
var MFG_YEAR_length=1;

/*	MFG_MONTH (1 char, 15)							
		J: Jan
		F: Feb	*/	
var MFG_MONTH_start=15;
var MFG_MONTH_length=1;

/*	MFG_BATCH (1 char, 16)
		1: ONE	*/
var MFG_BATCH_start=16;
var MFG_BATCH_length=1;

/*	QRcode (8 char, 17-24)
		1: ONE	*/
var QR_start=16;
var QR_length=8;




//Public 
function WWEEPROM(){
	var self=this;
}

setText=function(validlength,spacenum,start,text,callback) {
	if( text.length == validlength ) {
	at24.writeout(spacenum,start,text.split(""),function(err, suc) {
			if (err) {
				callback(err,null);
			}
			else {
				callback(null,suc);
			}
		});
	}
	else {
		callback("Your looking for a length of "+validlength+" characters. But you passed: "+serial_length,text.length,null);
	}
}





/*-------------------------------------------------------------------------------------------------------------------
SERIAL
-------------------------------------------------------------------------------------------------------------------*/
WWEEPROM.prototype.setSerial=function(serial,callback) {
	 setText(serial_length,serial_spacenum,serial_start,serial,callback);
}



WWEEPROM.prototype.readSerial=function(callback) {
	var self=this;
at24.readout(serial_spacenum,serial_start,(serial_start+serial_length),callback);
}

WWEEPROM.prototype.getSNpart=function(part,sn) {
	var self=this;
	switch (part) {
	case "BRAND": return sn.toString().substr(BRAND_start,BRAND_length); break;
	case "DEVICE": return sn.toString().substr(DEVICE_start,DEVICE_length); break;
	case "HWVERSION": return sn.toString().substr(HWVERSION_start,HWVERSION_length); break;
	case "UUID": return sn.toString().substr(UUID_start,UUID_length); break;
	case "RADIO_CONFIG": return sn.toString().substr(RADIO_CONFIG_start,RADIO_CONFIG_length); break;
	case "MFG_YEAR": return sn.toString().substr(MFG_YEAR_start,MFG_YEAR_length); break;
	case "MFG_MONTH": return sn.toString().substr(MFG_MONTH_start,MFG_MONTH_length); break;
	case "MFG_BATCH": return sn.toString().substr(MFG_BATCH_start,MFG_BATCH_length); break;
	case "QRCODE": return sn.toString().substr(QR_start,QR_length); break;
	}
}


/*-------------------------------------------------------------------------------------------------------------------
Hugekey
-------------------------------------------------------------------------------------------------------------------*/
WWEEPROM.prototype.setHugeKey=function(key,callback) {
	 setText(HugeKey_length,HugeKey_spacenum,HugeKey_start,key,callback);
}


WWEEPROM.prototype.readHugeKey=function(callback) {
	var self=this;
	at24.readout(HugeKey_spacenum,HugeKey_start,(HugeKey_start+HugeKey_length),callback);
}

/*-------------------------------------------------------------------------------------------------------------------
security key
-------------------------------------------------------------------------------------------------------------------*/
WWEEPROM.prototype.setsKey=function(key,callback) {
	 setText(sKey_length,sKey_spacenum,sKey_start,key,callback);
}

WWEEPROM.prototype.readsKey=function(callback) {
	var self=this;
	at24.readout(sKey_spacenum,sKey_start,(sKey_start+sKey_length),callback);
}

module.exports = WWEEPROM;
