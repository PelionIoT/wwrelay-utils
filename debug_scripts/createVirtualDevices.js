
let createVirtualDevices = () => {
	return new Promise(function(resolve, reject) {
		dev$.selectByID('VirtualDeviceDriver').call('listTemplates').then(function(templateResp, err) {
			if(templateResp.VirtualDeviceDriver.response.result) {
				console.log('Starting creating new virtual device')
				let templates = templateResp.VirtualDeviceDriver.response.result;
				var startDevices = async () => {
                    try {
                        for(var i = 0; i < templates.length; i++) {
                            console.log('Creating virtual device of type ' + templates[i]);
                            await dev$.selectByID('VirtualDeviceDriver').call('create', templates[i]).then(function(resp) {
							    console.log(resp.VirtualDeviceDriver.response.result);
							});
                            // await DCS.executeCommand(program.site, "id=\"VirtualDeviceDriver\"", "create", templates[i]).then(function(rsp) {
                            //     console.log(rsp);
                            // });
                        } 
                    }catch(err) {
                        reject(err);
                    } finally {
                        resolve();
                    }
                }
                startDevices();
			}else {
				return reject('Failed to list virtual device template list');
			}	
		})
	})
}

createVirtualDevices()