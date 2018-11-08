dev$.selectByID('VirtualDeviceDriver').call('deleteAll');
for(var i = 0; i < 20; i++) {
    dev$.selectByID('VirtualDeviceDriver').call('create', 'ContactSensor').then(function(resp) {
        console.log('Started controller ', resp);
    }, function(err) {
        console.error('Failed to start deviceController ' + err +  '  ' + JSON.stringify(err));
    });
}