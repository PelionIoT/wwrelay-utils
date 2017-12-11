var serialport = require('serialport');
var SerialPort = serialport.SerialPort;
var EventEmitter = require('events').EventEmitter;
var _ = require('lodash');

//Default options
var _options = {
	siodev: "/dev/ttyUSB0",
	baudrate: 115200,
	dataBits: 8,
	stopBits: 1,
	parity: 'none'
};

var logger = console;

var SerialCommInterface = function(options) {

	if(typeof options === 'undefined') {
		options = {};
		logger.warn('Using default SerialCommInterface options- ' + JSON.stringify(_options));
	}

	this._serialPort = null;
	this._siodev   = options.siodev   || _options.siodev;
	this._baudrate = options.baudrate || _options.baudrate;
	this._dataBits = options.dataBits || _options.dataBits;
	this._stopBits = options.stopBits || _options.stopBits;

	this.buffers = [];
};

SerialCommInterface.prototype = Object.create(EventEmitter.prototype);

SerialCommInterface.prototype.start = function() {
	var self = this;

	return new Promise(function(resolve, reject) {
		logger.log('Trying opening the port '+ self._siodev + ' with baudrate '+ self._baudrate);

		self._serialPort = new SerialPort(self._siodev, {
							baudrate: self._baudrate
         					// ,parser: serialport.parsers.readline("\n") //receive byte length data
							}, false); //openImmediately - false

		self._serialPort.open(function(err) {
			if(err) {
				logger.error('Error opening port '+ self._siodev + ' failed with error ', err);
				reject(new Error(err));
				return;
			}
			logger.log('Connection established successful on port '+ self._siodev);

			self._serialPort.on('data', function(data) {
				// console.log('data ', data);
				self.emit('data', data);
			}); //called on receiving data, default parser 'raw'- return buffer object

			self._serialPort.on('close', function() {
				logger.log('Port closed successful');
				self.emit('close');
			}); //Callback is called with no arguments when the port is closed. In the event of an error, an error event will be triggered

			self._serialPort.on('error', function(err) {
				if(err) {
					logger.error('Error event on serial port '+ err);
					self.emit('error', err);
					return;
				}
			}); //Callback is called with an error object whenever there is an error.

			self._serialPort.on('disconnect', function(err) {
				if(err) {
					logger.error('Serial port got disconnect with error '+ err);
					self.emit('disconnect', err);
					return;
				}
			}); //Callback is called with an error object.

			resolve();
		});
	});
};

SerialCommInterface.prototype.write = function(data, callback) {
	var self = this;

	if(self._serialPort.isOpen() === false) {
		if(callback && typeof callback === 'function') {
			callback(new Error('Port not open'));
		}
		return;
	}

	self._serialPort.write(data, function(err) {
		if(err) {
			logger.error('Write failed with error '+ err);
			return;
		}
		// logger.log('Write successful ' + data.toString('hex'));
	});
};

//Check is the serial port is open, returns boolean
SerialCommInterface.prototype.isOpen = function() {
	return this._serialPort.isOpen();
};

//Pauses an open connection
SerialCommInterface.prototype.pause = function() {
	return this._serialPort.pause();
};

//Resumes a paused connection
SerialCommInterface.prototype.resume = function() {
	return this._serialPort.resume();
};

//Flushes data received but not read
SerialCommInterface.prototype.flush = function() {
	var self = this;
	this._serialPort.flush(function(err) {
		if(err) {
			logger.error('Error while flushing the serial port '+ err);
			if(/Port is not open/.test(err)) {
				if(self._onPortClose && typeof self._onPortClose === 'function') self._onPortClose();
			}
			return;
		}
		return;
	});
};

//Waits until all output data has been transmitted to the serial port
SerialCommInterface.prototype.drain = function() {
	this._serialPort.drain(function(err) {
		if(err) {
			logger.error('Error while draining the serial port '+ err);
			return;
		}
		return;
	});
};


/**
 * Closes an open serial communication interface with ZW controller
 *
 * @method close
 */
SerialCommInterface.prototype.close = function() {
	var self = this;
	self._serialPort.close(function(err) {
		if(err) {
			logger.error('Error while closing the port '+ self._siodev + ' error ' + err);
			return;
		}
		logger.log('Closed open port successfully '+ self._siodev);
	});
};

module.exports = SerialCommInterface;
