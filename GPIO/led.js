#!/usr/bin/env node
 //use nodes script

var dev$Promise = require('/wigwag/FACTORY/utils/DevPromise.js');

var fs = require('fs');

var _valid_colors = ['red', 'green', 'blue', 'yellow', 'magenta', 'cyan', 'white', 'off'];

function _openFD(path, fd) {
  return new dev$Promise(null).when(function(token) {
    fs.open(path, "w", 0666, function(err, fd) {
      if (err) token.reject(err);
      else token.resolve(fd);
    });
  });
}

function _testArrayintwos(array) {
  if (array.length % 2 === 0) return true;
  else return false;
}

function _wrappedWrite(FD, stat) {
  FD = parseInt(FD);
  return new dev$Promise(null).when(function(token) {
    fs.write(FD, stat, null, null, function(err, written, string) {
      if (err) token.reject("error");
      else token.resolve("success");
    });
  });
}

function _writeColor(FR, FG, FB, r, g, b) {
  return new dev$Promise(null).join(_wrappedWrite(FR, r), _wrappedWrite(FB, b), _wrappedWrite(FG, g));
}

var LED = function LED() {
  //defining a var instead of this (works for variable & function) will create a private definition
  var self = this;
  this._lastCalltoEnableNotifications = true;
  this._EnabledNotifications = true;
  this._EnabledStatus = true;
  this._current_color;
  this._imblinking = false;
  this._colorray = [];
  this._ledReady = false;
  this.Promise_FD_red = _openFD('/sys/class/leds/red/brightness', this.FD_RED);
  this.Promise_FD_green = _openFD('/sys/class/leds/green/brightness', this.FD_GREEN);
  this.Promise_FD_blue = _openFD('/sys/class/leds/blue/brightness', this.FD_BLUE);

  this.Promise_FD_red.then(function(result) {
      this.FD_RED = result;
      fs.write(this.FD_RED, 0);
    },
    function(err) {});
  this.Promise_FD_green.then(function(result) {
      this.FD_GREEN = result;
      fs.write(this.FD_GREEN, 0);
    },
    function(err) {});
  this.Promise_FD_blue.then(function(result) {
      this.FD_BLUE = result;
      fs.write(this.FD_BLUE, 0);
    },
    function(err) {});

  if (LED.caller != LED.getInstance) {
    throw new Error("This object cannot be instanciated");
  }
}

LED.prototype.ColorLED = function(color, callback) {
  var self = this;
  //var r, g, b;
  var r = 0;
  var g = 0;
  var b = 0;

  var badcolor = false;
  switch (color) {
    case "red":
      r = 1;
      g = 0;
      b = 0;
      break;
    case "green":
      r = 0;
      g = 1;
      b = 0;
      break;
    case "blue":
      r = 0;
      g = 0;
      b = 1;
      break;
    case "yellow":
      r = 1;
      g = 1;
      b = 0;
      break;
    case "magenta":
      r = 1;
      g = 0;
      b = 1;
      break;
    case "cyan":
      r = 0;
      b = 1;
      g = 1;
      break;
    case "white":
      r = 1;
      g = 1;
      b = 1;
      break;
    case "off":
      r = 0;
      g = 0;
      b = 0;
      break;
    default:
      badcolor = true;
      break;
  }

  if (!badcolor) {
    this._current_color = color;
    dev$Promise.all([this.Promise_FD_red, this.Promise_FD_green, this.Promise_FD_blue]).then(function(err, result) {
      var stuff = new dev$Promise(null).join(_wrappedWrite(this.FD_RED, r), _wrappedWrite(this.FD_BLUE, b), _wrappedWrite(this.FD_GREEN, g)).then(function(stat) {}, function(err) {});
    });
  }

  else {
    callback("Color: " + color + " is not supported", null);
  }
}

LED.prototype._blinkColor = function() {
  var self = this;
  color = this._colorray.shift();
  this._colorray.push(color);
  time = this._colorray.shift();
  this._colorray.push(time);
  this.ColorLED(color);
  setTimeout(function() {
    if (self._imblinking) self._blinkColor();
  }, time);
}

LED.prototype._blinkColorRecurse = function(array, callback) {
  var self = this;
  if (array.length == 0) {
    callback(null, "complete notification");
  }
  else {
    var color = array.shift();
    var time = array.shift();
    this.ColorLED(color);
    setTimeout(function() {
      //var self=this;
      self._blinkColorRecurse(array, callback);
    }, time);
  }
}

LED.prototype._setColor = function(color) {
  this._imblinking = false;
  this._current_color = color;
  this.ColorLED(color);
}

LED.prototype._blinkColorLoop = function(array, callback) {
  if (!_testArrayintwos(array)) {
    callback("Error: Color array must be in multiple of twos.", null);
  }
  else {
    this._colorray = array;
    if (!this._imblinking) {
      this._imblinking = true;
      this._blinkColor();
    }
    callback(null, "Command Accepted");
  }
}

LED.prototype._blinkColorReturn = function(array, callback) {
  var self = this;
  if (!_testArrayintwos(array)) {
    callback("Error: Color array must be in multiple of twos.", null);
  }
  else {
    if (!this._imblinking) {
      array.push(this._current_color, 1);
      this._blinkColorRecurse(array, callback);
    }
    else {
      this._imblinking = false;
      this._blinkColorRecurse(array, function(err, done) {
        self._imblinking = true;
        self._blinkColor();
        callback(err, done);
      });
    }
  }
}

/* set status,  If you have more status' for the relay, this is the palce to add them. here are two primary options.  
1.  to simply set a fixed color that does not blink
    this._setColor("color")
2. to set a blink pattern, provide an array in the format ["color", time, "color", time], to:
    this.blinkColorLoop(["color",time,"color",time,...],callback);

valid colors for both functions: red, green, blue, yellow, magenta, cyan, white, or off.
valid time: miliseconds eg 2000 = 2 seconds
*/
LED.prototype.setStatus = function(status, callback) {
  this._savedStatus = status;
  if (this._EnabledStatus) {
    switch (status) {
      case "connected":
        this._setColor("blue");
        callback(null, "accepted");
        break;
      case "searching":
        this._blinkColorLoop(["blue", 500, "off", 500], callback);
        break;
      case "crashed":
        this._blinkColorLoop(["red", 1000, "off", 500], callback);
        break;
      case "deviceJSup":
        this._blinkColorLoop(["green", 200, "off", 200], callback);
        break;
      case "haveIP":
        this._setColor("green");
        break;
      case "loggedin":
        this._blinkColorLoop(["blue", 2000, "magenta", 500], callback);
        break;
    }
  }
  else callback("Error: setStatus disabled, saved request for future.", null);
}

/* notifications,  If you have more notifications' for the relay, this is the palce to add them. here are two primary options.  
1. to set a blink pattern, provide an array in the format ["color", time, "color", time], to:
    this.blinkColorReturn(["color",time,"color",time,...],callback);

valid colors for both functions: red, green, blue, yellow, magenta, cyan, white, or off.
valid time: miliseconds eg 2000 = 2 seconds
*/
LED.prototype.notify = function(notification, callback) {
  if (this._EnabledNotifications && this._EnabledStatus) {
    if (!this._notifying) {
      switch (notification) {
        case "radio":
          this._blinkColorReturn(["green", 150], callback);
          break;
        case "when":
          this._blinkColorReturn(["white", 150, "off", 150], callback);
          break;
        case "login":
          this._blinkColorReturn(["magenta", 1000], callback);
          break;

      }
    }
    else callback("Error: notification in progress", null);
  }
  else callback("Error: notifications are disable", null);
}

LED.prototype.enableNotifications = function() {
  this._EnabledNotifications = true;
  this._lastCalltoEnableNotifications = true;
}

LED.prototype.disableNotifications = function() {
  this._EnabledNotifications = false;
  this._lastCalltoEnableNotifications = false;
}

LED.prototype.restoreLED = function() {
  this._EnabledStatus = true;
  this._EnabledNotifications = this._lastCalltoEnableNotifications;
  this.setStatus(this._savedStatus, function() {});
}

LED.prototype.disableLED = function() {
  this._EnabledStatus = false;
  this._EnabledNotifications = false;
  this._setColor("off");
}

LED.instance = null;
/**
 * LED getInstance definition
 * @return LED class
 */
LED.getInstance = function() {
  if (this.instance === null) {
    this.instance = new LED();
  }
  return this.instance;
}

//a Singleton.  There is only 1 led, so the state should be treated universally throughout the entire system.
module.exports = LED.getInstance();