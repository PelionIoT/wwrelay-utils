dev$.selectByID('VirtualDeviceDriver').call('create', 'LightBulb').then(function(resp) {
    console.log(resp.VirtualDeviceDriver.response.result);
});
dev$.selectByID('VirtualDeviceDriver').call('create', 'Thermostat').then(function(resp) {
    console.log(resp.VirtualDeviceDriver.response.result);
});
dev$.selectByID('VirtualDeviceDriver').call('create', 'Temperature').then(function(resp) {
    console.log(resp.VirtualDeviceDriver.response.result);
});
dev$.selectByID('VirtualDeviceDriver').call('create', 'MotionSensor').then(function(resp) {
    console.log(resp.VirtualDeviceDriver.response.result);
});