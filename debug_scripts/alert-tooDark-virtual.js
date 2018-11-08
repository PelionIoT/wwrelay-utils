var resourceID;

function startApp() {
    var luminance;
    var currentlyRaised = false;

    function raiseAlert(id, luminance) {
        dev$.alert('Too dark', 'warning', true, { 
            luminance: luminance,
            id: id
        });
        currentlyRaised = true;
        log.info(id + ' Too dark, alert raised!!');
    }

    function lowerAlert(id, luminance) {
        dev$.alert('Too dark', 'warning', false, {
            luminance: luminance,
            id: id
        });
        currentlyRaised = false;
        log.info(id + ' Too dark, alert lowered!!');
    }

    function checkAlertCondition(id, luminance) {
        if(luminance < 60 && !currentlyRaised) {
            raiseAlert(id, luminance);
        } else if(luminance > 60 && currentlyRaised) {
            lowerAlert(id, luminance);
        }
    }

    var allStates = dev$.selectByID(resourceID);
    allStates.subscribeToState('+');
    allStates.on('state', function(id, type, data) { 
        if(id == resourceID) {
            luminance = data;
            log.info('Got luminance state from ' + resourceID + ' data ' + luminance);
            checkAlertCondition(id, data);
        }
    });

    var allEvents = dev$.selectByID(resourceID);
    allEvents.subscribeToEvent('+');
    allEvents.on('event', function(id, type, data) {
        if(id == resourceID) {
            luminance = data;
            log.info('Got luminance event from ' + resourceID + ' data ' + luminance);
            checkAlertCondition(id, data);
        }
    });

    setInterval(function() {
        dev$.selectByID(resourceID).get('luminance').then(function(resp) {
            if(resp && resp[resourceID] && resp[resourceID].response && resp[resourceID].response.result) {
                if(typeof resp[resourceID].response.result === 'number') {
                    luminance = resp[resourceID].response.result;
                    log.info('Got luminance from ' + resourceID + ' data ' + luminance);
                    checkAlertCondition(resourceID, luminance);
                }
            }
        });
    }, 5000);


    setInterval(function() {
        dev$.selectByID(resourceID).call('emit');
    }, 1000);
}

function getLuminanceSensor() {
    //Find luminance resource type resourceId
    dev$.select('id=*').listResources().then(function(resources) {
        var found = false;
        Object.keys(resources).forEach(function(resrc) {
            if(resources[resrc].type == "Core/Devices/Virtual/Luminance") {
                found = true;
                resourceID = resrc;
            }
        });

        if(found) {
            startApp();
        } else {
            //Create luminance sensor
            dev$.selectByID('VirtualDeviceDriver').call('create', 'Luminance').then(function(resp) {
                if(resp && resp.VirtualDeviceDriver && resp.VirtualDeviceDriver.response && resp.VirtualDeviceDriver.response.result) {
                    log.info(resp.VirtualDeviceDriver.response.result);
                    getLuminanceSensor();
                } else {
                    log.error('Failed to create luminance sensor ' + JSON.stringify(resp));
                }
            }, function(err) {
                log.error('Failed to create luminance sensor ' + err);
            });
        }
    });
}

getLuminanceSensor();