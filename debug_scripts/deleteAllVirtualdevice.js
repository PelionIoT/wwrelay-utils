let deleteAllVirtualdevices = () => {
	console.log('Staring deleting all previous virtual devices')
	dev$.selectByID('VirtualDeviceDriver').call('deleteAll').then(function(resp, err) {
		console.log('Virtual device delete complete')	
	})
}

deleteAllVirtualdevices()