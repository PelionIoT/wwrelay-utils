var i2c = require('i2c');
var i2cbus = '/dev/i2c-0';
//the PMU AXP that is used on the relay can charge the RTC battery.  In order to successfully do so, we need to tell the PMU to charge at a voltage of 2.97.  This is enabled by writing an 0x82 into the data address 0x35, of the AXP Chip (@ address 0x35) on the i2c-0 bus.
var chipaddress = 0x34;
var dataaddress = 0x35;
var data = 0x82; //decimal = 130;

PMU = new i2c(chipaddress, {
	device: i2cbus
});

PMU.readBytes(dataaddress, 1, function(err, res) {
	if (err) console.log("Error: %s", err);
	if (res.readUInt8(0) != data) {
		console.log("Currently set to: 0x%s.  Setting to 0x82", res.readUInt8(0).toString(16));
		PMU.writeBytes(dataaddress, [data], function(err) {
			if (err) console.log("Error: %s", err);
		});
	}
	else console.log("RTC battery is charging: we are currently set to 0x%s", res.readUInt8(0).toString(16));
});