'use strict';
try {
	const fs = require('fs');
	const execSync = require('child_process').execSync;
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

	function updateMccConfig() {
		return new Promise(function(resolve, reject) {
			if(old_eeprom.mcc_config) {
		        fs.stat('/userdata/mbed/mcc_config', function(err, stats) {
		            if(err) {
		                reject('Mbed gateway. Failed to get pal directory stats ', err);
		                return;
		            }
		            if(stats.isDirectory()) {
		                // execSync('cp -R ./pal ./mcc_config');
		                execSync('cd /userdata/mbed; tar -czvf mcc_config.tar.gz mcc_config; cd -');
		                // if(ee.mbed) {
		                    delete new_eeprom.mbed;
		                    new_eeprom.mcc_config = fs.readFileSync('/userdata/mbed/mcc_config.tar.gz', 'hex');
		                    resolve(new_eeprom);
		                // } else {
		                    // reject('Mbed gateway. Did not find the mbed device certs and enrollment id!');
		                    // return;
		                // }
		            } else {
		                reject('Mbed gateway. Failed to locate mcc_config directory!');
		                return;
		            }
		        });           
			} else {
				console.warn('NOT UPDATING MCC_CONFIG AS IT IS NOT FOUND IN THE OLD EEPROM!');
				resolve();
			}
		});
	}

	updateMccConfig().then(function() {
		console.log("Writing new eeprom to a file- new_eeprom.json");
		fs.writeFileSync('./new_eeprom.json', JSON.stringify(new_eeprom, null, 4), 'utf8');	
		process.exit(0);
	}, function(err) {
		console.error('FAILED ', err);
		process.exit(1);
	})
} catch(err) {
	console.error('Failed with error ', err);
	process.exit(1);
}
