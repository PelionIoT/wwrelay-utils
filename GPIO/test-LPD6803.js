var led = require('./LPD6803.js');

console.log("Test\n1) You will now see a Green LED for about 1 second.\n2) followed by a one time alert (blue in color) for 500ms.\n3) followed by a green for about 3.5 seconds\n4) followed by a green with blinking red for about 15 seconds\n5) folowed by solid green permenently");

var stuff = led.init();
//Do not use my private functions.  Only these two:
//led_setcolor(R,G,B);  //off =0, on full bright=30.  scale 0-30
//led_setalert(R,G,B);  //off=0, on full bright=30. scale 0-30
stuff.then(function(result) {
	led.setcolor(0, 10, 0);
	setTimeout(function() {
		led.alertOneTime(0, 0, 10);
	}, 1000);
	setTimeout(function() {
		led.alertOn(10, 0, 0);
	}, 5000);
	setTimeout(function() {
		led.alertOff();
	}, 20000);
}, function(err) {});
// setTimeout(function() {
// 	console.log("Imdone");
// }, 3000);
//direct_test();
//console_grabber();
//status_tests();
//api_test();