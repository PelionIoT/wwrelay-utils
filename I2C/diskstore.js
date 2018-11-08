var mkdirp = require('mkdirp');
var mountutil = require('linux-mountutils');
var Promise = require('es6-promise').Promise;
var fs = require('fs');

function diskstorage(dev, mp, storepoint) {
	mkdirp.sync(mp);
	this.sp = storepoint;
	this.dev = dev;
	this.mountPoint = mp;
	this.previouslymounted = true;
	this.mount;

	//For some reason in new kernel setup do not work. This should anyways try to create .ssl directory
	mkdirp.sync(this.mountPoint + "/" + this.sp);
}

diskstorage.prototype.setup = function() {
	var self = this;
	return new Promise(function(resolve, reject) {
		if(typeof self.dev !== 'undefined' && self.dev.length !== 0) {
			self._checkMount().then(function(result) {
				console.log("mount status ", result);
				self.mountPoint = result.mountpoint;
				self.previouslymounted = true;
				self.mount = result;
				resolve();
			}).catch(function(error) {
				console.log("were not mounted ", error);
				self.previouslymounted = false;
				self._mount().then(function(result) {
					console.log("we tried to mount and did it: ", result);
					return self._checkMount().then(function(result) {
						self.previouslymounted = true;
						self.mountPoint = result.mountpoint;
						self.mount = result;
						resolve();
					}, function(err) {
						reject(err);
					});
				}).catch(function(error) {
					console.log("Disksore couldn't do the prper mounting ", error);
					self.previouslymounted = false;
					self.mount = null;
					reject(error);
				});
			});
		}
	});
};

diskstorage.prototype._checkMount = function() {
	var self = this;
	return new Promise(function(resolve, reject) {
		var ret = mountutil.isMounted(self.dev, true);
		if (ret.mounted) {
			resolve(ret);
		}
		else {
			reject("not mounted--------------------------------------");
		}
	});
}

diskstorage.prototype._mount = function() {
	var self = this;
	return new Promise(function(resolve, reject) {
		var ret = mountutil.isMounted(self.dev, true);
		if (ret.mounted) {
			resolve(ret);
		}
		else {
			mountutil.mount(self.dev, self.mountPoint, {
				"noSudo": true
			}, function(result) {
				if (result.error) {
					reject(result.error + " (" + self.mountPoint + ")");
				}
				else {
					resolve(result);
				}
			});
		}
	});
}

diskstorage.prototype._umount = function() {
	console.trace("umount called... this is bad");
	var self = this;
	return new Promise(function(resolve, reject) {
		var ret = mountutil.isMounted(self.dev, true);
		if (ret.mounted) {
			mountutil.umount(self.dev, true, {
				"removedir": false
			}, function(result) {
				if (result.error) {
					reject(result.error);
				}
				else {
					resolve(result);
				}

			});

		}
		else {
			resolve("_Umount success " + self.dev);
		}
	});
}

diskstorage.prototype._readStore = function(path) {
	var self = this;
	options = "utf8";
	return new Promise(function(resolve, reject) {
		fs.readFile(self.mountPoint + "/" + self.sp + "/" + path, options, function(error, data) {
			if (error) {
				reject(error);
			}
			else {
				resolve(data);
			}
		});
	});
}

diskstorage.prototype._writeStore = function(path, data, options) {
	var self = this;
	return new Promise(function(resolve, reject) {
		fs.writeFileSync(path, data, options || 'utf8');
		resolve();
	});
}

diskstorage.prototype._eraseStore = function(path) {
	var self = this;
	return new Promise(function(resolve, reject) {
		console.log("unlinking " + path);
		fs.unlinkSync(path);
		resolve();
	});
}

diskstorage.prototype.getFile = function(path) {
	var self = this;
	return self._readStore(path);
}
diskstorage.prototype.cpFile = function(relativePath, path, overwrite) {
	var self = this;
	return new Promise(function(resolve, reject) {
		//console.log("relativepath: " + relativePath + "\npath: " + path + "\noverwrite: " + overwrite);
		self._readStore(relativePath).then(function(result) {
			//console.log("info", "returning promise resolved: " + result);
			fs.exists(path, function(exists) {
				if (exists && overwrite == "overwrite" || (!exists)) {
					console.log("caling to write: " + path);
					self._writeStore(path, result.toString()).then(function() {
						resolve();
					})
				}
				else {
					resolve(result);
				}

			}).then(function(result) {
				resolve(result);
			}).catch(function(error) {
				//console.log("debug","returning promise errored: "+error);
				reject(error);
			});
		}, function(err) {
			reject(err);
		});

	});
}

diskstorage.prototype.destroyFile = function(relativePath) {
	var self = this;
	return this._eraseStore(self.mountPoint + "/" + self.sp + "/" + relativePath);
}

diskstorage.prototype.setFile = function(relativePath, data, options) {
	var self = this;
	return this._writeStore(self.mountPoint + "/" + self.sp + "/" + relativePath, data, options);
}

diskstorage.prototype.disconnect = function() {
	var self = this;
	if (self.previouslymounted != true) {
		return self._umount();
	}
	else {
		return new Promise(function(resolve, reject) {
			resolve("done");
		});
	}
}

module.exports = diskstorage;