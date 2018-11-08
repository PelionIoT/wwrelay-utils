var allEvents = dev$.selectByID("ZW010f200108013");
allEvents.subscribeToEvent('+');
allEvents.on('event', function(id, type, data) {
    if(id == 'ZW010f200108013' && type == 'motion' && data === true) {
        dev$.selectByID('AD_HOC_ELECTRONICS_04019f5a').set('brightness', 0.5);
    }
});