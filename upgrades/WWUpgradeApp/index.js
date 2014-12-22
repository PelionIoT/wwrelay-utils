var tools = require('Class/coreTools.js');
var log = tools.log;

var util = require('util');
var path = require('path');
var App = require('Class/App');
var express = require('express');
var morgan = require('morgan');
var bodyParser = require('body-parser');
var dev$Promise = require('Class/DevPromise');
var upgradeUtils = require('./upgradeUtils.js');


var WWUpgradeApp = App.create('WWUpgradeApp', function() {
    var self = this;
    var app = null;

    this.start = function () {
        log.debug("-----> wwupgradeapp start("+this.id()+")");
        return new dev$Promise().when(function(p) {

            //  Path to local versions file
            var versionFile = '/etc/wigwag/versions.json'

            var versCallback = function(a, b) {
                 console.log("Testing");
	    };

           upgradeUtils.init(versionFile, versCallback);

        });
    };

    this.stop = function() {
        return new dev$Promise().when(function(p) {
            p.resolve();
        });
    };
});

module.exports = WWUpgradeApp;
