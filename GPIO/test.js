//var led = require('./ledfake.js');
var test = require('./ledfake');
test._setColor("green", function(yo) {
	console.log("yo");
});
test._blinkColorLoop("red", function(yo) {
	console.log("yo");
});