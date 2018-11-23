'use strict';
try {
	const fs = require('fs');
	const old_eeprom = JSON.parse(fs.readFileSync('./old_eeprom.json', 'utf8'));
	const device_key = fs.readFileSync('./temp_certs/device_private_key.pem', 'utf8');
	const device_cert = fs.readFileSync('./temp_certs/device_cert.pem', 'utf8');
	const root_cert = fs.readFileSync('./temp_certs/root_cert.pem', 'utf8');
	const intermediate_cert = fs.readFileSync('./temp_certs/intermediate_cert.pem', 'utf8');

	var new_eeprom = JSON.parse(JSON.stringify(old_eeprom));
	// console.log(new_eeprom);
	new_eeprom.ssl.client.key = device_key;
	new_eeprom.ssl.client.certificate = device_cert;
	new_eeprom.ssl.server.key = device_key;
	new_eeprom.ssl.server.certificate = device_cert;
	new_eeprom.ssl.ca.ca = root_cert;
	new_eeprom.ssl.ca.intermediate = intermediate_cert;
	new_eeprom.deviceID = process.argv[2];

	console.log("Writing new eeprom to a file- new_eeprom.json");
	fs.writeFileSync('./new_eeprom.json', JSON.stringify(new_eeprom, null, 4), 'utf8');
	//console.log(new_eeprom.ssl);
	process.exit(0);
} catch(err) {
	console.error('Failed with error ', err);
	process.exit(1);
}
