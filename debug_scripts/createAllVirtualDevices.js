logger = console;
dev$.selectByID('VirtualDeviceDriver').call('listTemplates').then(function(resp) {
    if(resp && resp.VirtualDeviceDriver && resp.VirtualDeviceDriver.response && resp.VirtualDeviceDriver.response.result) {
        let templates = resp.VirtualDeviceDriver.response.result;
        let p = [];
        templates.forEach(function(tempType) {
            logger.info('Creating virtual device of type ' + tempType);
            p.push(dev$.selectByID('VirtualDeviceDriver').call('create', tempType));
        });
        Promise.all(p).then(function(result) {
          logger.info('Completed ', result);
        }, function(err) {
            logger.error('Failed with err ', err);
        });
    } else {
        logger.error('Failed to list virtual device template list');
    }
}, function(err) {
    logger.error('Failed to create virtual devices ' + err);
});