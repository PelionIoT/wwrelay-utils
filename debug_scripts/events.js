var allEvents = dev$.select('id=*');
allEvents.subscribeToEvent('+');
allEvents.on('event', function(id, type, data) {  console.log('Event- Device ' + id + ' type ' + type + ' data ' + JSON.stringify(data)); });

var allStates = dev$.select('id=*');
allStates.subscribeToState('+');
allStates.on('state', function(id, type, data) { console.log('State- Device ' + id + ' type ' + type + ' data ' + JSON.stringify(data)); });

var allDiscover = dev$.select('id=*');
allDiscover.subscribeToEvent('discovery');
allDiscover.on('event', function(id, type, data) { console.log('Discovery- Device ' + id + ' type ' + type + ' data ' + JSON.stringify(data)); });