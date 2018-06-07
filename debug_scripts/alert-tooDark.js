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

var allStates = dev$.select('id=*');
allStates.subscribeToState('+');
allStates.on('state', function(id, type, data) {
    if(type === 'luminance') {
        log.info(id + ' luminance level ' + data);
        checkAlertCondition(id, data);
    }
});

var allEvents = dev$.select('id=*');
allEvents.subscribeToEvent('+');
allEvents.on('event', function(id, type, data) {
    if(type === 'luminance') {
        log.info(id + ' luminance level ' + data);
        checkAlertCondition(id, data);
    }
});