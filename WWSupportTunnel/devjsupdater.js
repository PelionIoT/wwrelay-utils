var util = require('util');
var events = require('events');
//var Promise = require('es6-promise').Promise;

var DeviceJSUpdater = function(options) {
    events.EventEmitter.call(this);
};

util.inherits(DeviceJSUpdater, events.EventEmitter);

// Package has been downloaded. It is not already present in the versions file. Needs to be installed/added to versions file
DeviceJSUpdater.prototype.installPackage = function(packageName, version) {
    return new Promise(function(resolve, reject) {
        resolve();
    });
};

// Package is already installed. Needs to be uninstalled/removed from versions file
DeviceJSUpdater.prototype.uninstallPackage = function(packageName, version) {
    return new Promise(function(resolve, reject) {
        resolve();
    });
};

// Old version of package is already installed. New version has been downloaded but not installed. New version
// needs to replace the old version and versions file updated to reflect the version change
DeviceJSUpdater.prototype.updatePackage = function(pacakgeName, version) {
    return new Promise(function(resolve, reject) {
        resolve();
    });
};

// Download package
DeviceJSUpdater.prototype.downloadPackage = function(packageName, version) {
    return new Promise(function(resolve, reject) {
        resolve();
    });
};

// See which packages are out of date
DeviceJSUpdater.prototype.checkForUpdates = function() {
    return new Promise(function(resolve, reject) {
        resolve([]);
    });
};

module.exports = DeviceJSUpdater;

