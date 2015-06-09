var led = require('./led.js');
var led2 = require('./led.js');
var time = 1;

var dev$Promise = require('/wigwag/FACTORY/utils/DevPromise.js');

function _timeout(timeout) {
	time = time + timeout;
	return new dev$Promise(null).when(function(token) {
		setTimeout(function() {
			token.resolve("hi");
		}, time);
	});
}

function _wrapptimeout(title, timeinc, func) {
	time = time + timeinc;
	var t1 = time;
	setTimeout(function() {
		var t2 = t1;
		console.log(title + " - %s ms", t1);
		func();
	}, time);
}

function simple_RGB(color) {
	led.__setColor(color, function(err, good) {
		if (err) console.log(err);
	});
}

function api_test() {
	var stdtime = 5000;

	_timeout(stdtime).then(function(call) {
		console.log("Displaying red with internal call for %s ms", stdtime);
		simple_RGB("red");
	});
	_timeout(stdtime).then(function(call) {
		console.log("Disabling notifications", stdtime);
		led.disableNotifications();
		console.log("calling notify 3 times");
		led.notify("radio", function(err, success) {
			console.log("err %s succ %s", err, succ);
		});
		led.notify("radio", function(err, success) {
			console.log("err %s succ %s", err, succ);
		});
		led.notify("radio", function(err, success) {
			console.log("err %s succ %s", err, succ);
		});
	});
	_timeout(stdtime).then(function(call) {
		console.log("Eabling notify.  Shouldn't see anything", stdtime);
		led.enableNotifications();
	});

	_timeout(stdtime).then(function(call) {
		console.log("Setting status to searching for %s ms, should see blue blink", stdtime);
		led.setStatus("searching");
	});
	_timeout(stdtime).then(function(call) {
		console.log("Setting a notification Radio. (see a rapid  green blink.)", stdtime);
		led.notify("radio", function() {});
	});
	_timeout(stdtime).then(function(call) {
		console.log("Disabling LED", stdtime);
		led.disableLED();
		console.log("Setting status to haveIP. Shouldn't see anything because LED disabled", stdtime);
		led.setStatus("crashed");
	});
	_timeout(stdtime).then(function(call) {
		console.log("Setting status to crashed. Shouldn't see anything  because lED disabled", stdtime);
		led.setStatus("crashed");
	});
	_timeout(stdtime).then(function(call) {
		console.log("Enabling LED, we should see crashed (red blink) because it was the last status set", stdtime);
		led.restoreLED();
	});
	_timeout(stdtime).then(function(call) {
		console.log("Setting status connected", stdtime);
		led.setStatus("connected");
	});
	_timeout(stdtime).then(function(call) {
		console.log("sending a login (magenta) notification");
		led.notify("login", function() {});
	});
	_timeout(stdtime).then(function(call) {
		console.log("Disabling LED again to test that notifications remain off when say off");
		led.disableLED();
		console.log("Just disabled LED, so both LED and notifications will not light the LED. If we were to call restoreLED right now, the LED + notifications would come back, because the last request state for LED Notifications was enabled.  Lets now make a call to disableNotifications.");
		led.disableNotifications();
	});
	_timeout(stdtime).then(function(call) {
		console.log("calling restoreLED (notifications shouldn't get enabled)");
		led.restoreLED();
	});
	_timeout(stdtime).then(function(call) {
		console.log("sending a when notification (white) notification.  (you shouldn't see it.)");
		led.notify("when", function() {});
	});
	_timeout(stdtime).then(function(call) {
		console.log("enablingNotifications.  you shouldn't see previous notifications");
		led.enableNotifications();
	});
	_timeout(stdtime).then(function(call) {
		console.log("Setting a notification Radio. (see a rapid  green blink.)", stdtime);
		led.notify("radio", function() {});
	});
}

function status_tests() {
	var stdtime = 5000;
	_timeout(stdtime).then(function(call) {
		cmd = "connected";
		console.log("%s %s ms", cmd, stdtime);
		led.setStatus(cmd);
	});
	_timeout(stdtime).then(function(call) {
		cmd = "searching";
		console.log("%s %s ms", cmd, stdtime);
		led.setStatus(cmd);
	});

	_timeout(stdtime).then(function(call) {
		cmd = "deviceJSup";
		console.log("%s %s ms", cmd, stdtime);
		led.setStatus(cmd);
	});

	_timeout(stdtime).then(function(call) {
		cmd = "haveIP";
		console.log("%s %s ms", cmd, stdtime);
		led.setStatus(cmd);
	});

	_timeout(stdtime).then(function(call) {
		cmd = "loggedin";
		console.log("%s %s ms", cmd, stdtime);
		led.setStatus(cmd);
	});

	_timeout(stdtime).then(function(call) {
		cmd = "crashed";
		console.log("%s %s ms", cmd, stdtime);
		led.setStatus(cmd);
	});
}

status_tests();
//api_test();