
var execSync = require('child_process').execSync;
function createVirtualDevices() {
    console.log('Creating virtual devices...');
    return new Promise(function(resolve, reject) {
        dev$.selectByID('VirtualDeviceDriver').call('listTemplates').then(function(resp) {
            if(resp && resp.VirtualDeviceDriver && resp.VirtualDeviceDriver.response && resp.VirtualDeviceDriver.response.result) {
                let templates = resp.VirtualDeviceDriver.response.result;
                let p = [];
                templates.forEach(function(tempType) {
                    console.log('Creating virtual device of type ' + tempType);
                    p.push(dev$.selectByID('VirtualDeviceDriver').call('create', tempType));
                    p.push(dev$.selectByID('VirtualDeviceDriver').call('create', tempType));
                    p.push(dev$.selectByID('VirtualDeviceDriver').call('create', tempType));
                    p.push(dev$.selectByID('VirtualDeviceDriver').call('create', tempType));
                });
                Promise.all(p).then(function() {
                    console.log("Successfully created lot of virtual devices. Rebooting in 5 seconds...");
                    setTimeout(function() {
                        execSync('reboot');
                    }, 5000);
                    resolve();
                }, function(err) {
                    return reject(err);
                });
            } else {
                return reject('Failed to list virtual device template list');
            }
        }, function(err) {
            console.error('Failed to create virtual devices ' + err);
            return reject(err);
        });
    });
}

createVirtualDevices();