var fs = require('fs');
var util = require('util');

// NPM stuff:
var program = require('commander');
// in /lib:
JSON.minify = JSON.minify || require("./lib/json.minify.js"); // allows comments in JSON


var WigWagSlipWriter = function(baseFirmwareFile, offsets, relayconfFile) {
	//console.log(baseFirmwareFile);
	//this._offsets = offsets;
	this._data = fs.readFileSync(baseFirmwareFile, 'hex');
	this._prefixbytes = offsets.prefix_name.bytes;
	this._postfixbytes = offsets.postfix_name.bytes;
	// console.log("prefix: ", this._prefixbytes);
	// console.log("postfix: ", this._postfixbytes);
	this._devices = JSON.parse(JSON.minify(fs.readFileSync(relayconfFile, 'utf8')));
	this._sixBMAC = this._devices.runtimeConfig.services.sixLBR.config.sixlbr.sixBMAC;
	// console.log("sixBMAC: ", this._sixBMAC);
};

WigWagSlipWriter.prototype.reverseEndian = function(hexstring) {
	//console.log("String ", hexstring);
	var val = new Buffer(hexstring, 'hex');
	var buffer = new Buffer(8);
	for (var i = 0; i < buffer.length; i++) {
		buffer[i] = val[7 - i];	
	};
	//console.log("Reversed ", buffer);
	return buffer.toString('hex');
};

program	
	.command("embedMAC <basefirmware> <slipconf> <relayconf>")
	.description("Embed MAC into slip-radio firmware")
	.action(function(baseFirmwareFile, slipconfigFile, relayconfFile) {
		try {
			var config = JSON.parse(JSON.minify(fs.readFileSync(slipconfigFile, 'utf8')));
			//console.log(config);	
			var firmwareWriter = new WigWagSlipWriter(baseFirmwareFile, config.block.segment_offsets, relayconfFile);
			var prefix = firmwareWriter.reverseEndian(firmwareWriter._prefixbytes);
			var postfix = firmwareWriter.reverseEndian(firmwareWriter._postfixbytes);
			var sixBMAC = firmwareWriter.reverseEndian(firmwareWriter._sixBMAC);
			console.log("Prefix reverseEndian: " + prefix);
				console.log("Postfix reverseEndian: " + postfix);
			console.log("New MAC: " + sixBMAC);

			prefixindex = firmwareWriter._data.indexOf(prefix);
			postfixindex = firmwareWriter._data.indexOf(postfix);
			console.log("PreIndex: " + prefixindex);
			console.log("PostIndex: " + postfixindex);

			console.log("Present MAC: " + firmwareWriter._data.slice(prefixindex + 16, postfixindex));

			var bytes = new Buffer(firmwareWriter._data, 'hex');
			bytes.write(sixBMAC, (prefixindex + 16) / 2, 8, 'hex');

			fs.writeFile(baseFirmwareFile, bytes, function(err, data) {
				if(err)
					throw err;
				console.log('complete');
			})
		}
		catch(error) {
			console.log('An error occurred', error.stack);
		}
	});

program.parse(process.argv);