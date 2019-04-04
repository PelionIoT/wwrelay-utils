/*
 * Copyright (c) 2018, Arm Limited and affiliates.
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

var led = require('./led.js');
var led2 = require('./led.js');
var fs = require('fs');

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
		//led.setStatus(cmd);
		led._blinkColorLoop(["blue", 500, "off", 500], callback);
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

function direct_test() {

	for (var i = 0; i < 50; i++) {
		(function() {
			var stdtime = 1000;
			var mine = i;
			_timeout(stdtime).then(function(call) {

				cmd = "connected";
				console.log("%s %s ms", cmd, stdtime);
				//led.setStatus(cmd);
				var num = (mine % 7);
				console.log("num: %s, mine %s", num, mine);
				led._blinkColorLoop(['green', 100, 'off', 100], function(err, sucess) {
					if (err) {
						console.log("color change error " + err);
					}
					else {
						console.log("color change success: " + sucess);
					}
				});
			});
		})();
	}
}

function crushit() {

	var temp;

}

function console_grabber() {
	console.log("done");
	led._setColor("off");

	var readline = require('readline'),
		rl = readline.createInterface(process.stdin, process.stdout);

	rl.setPrompt('color> ');
	rl.prompt();

	rl.on('line', function(line) {

		if (line == "r") led._setColor("red");
		else if (line == "g") led._setColor("green");
		else if (line == "b") led._setColor("blue");

		else if (line == "br") {
			led._blinkColorLoop(['red', 500, 'off', 500], function() {});
		}
		else if (line == "bb") {
			led._blinkColorLoop(['blue', 500, 'off', 500], function() {});
		}
		else if (line == "bg") {
			led._blinkColorLoop(['green', 500, 'off', 500], function() {});
		}
		else {
			console.log("not a valid color: " + line);
		}
		fs.appendFile('/wigwag/log/dummy.out', "command line got: " + line + "\n", function(err) {
			if (err) throw err;
		});
		rl.prompt();
	}).on('close', function() {
		console.log('Have a great day !');
		process.exit(0);
	});
}

direct_test();
console_grabber();
//status_tests();
//api_test();