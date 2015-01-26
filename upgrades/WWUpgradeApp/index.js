var tools = require('Class/coreTools.js');
var log = tools.log;
var App = require('Class/App');
var express = require('express');
var dev$Promise = require('Class/DevPromise');
var upgradeUtils = require('./upgradeUtils.js');


var WWUpgradeApp = App.create('WWUpgradeApp', function() {
    var self = this;
    var app = null;
    var localVersions;
    var cloudVersions;

    this.start = function () {
        log.debug("-----> wwupgradeapp start("+this.id()+")");

        var configuration = this.configuration();

        return new dev$Promise().when(function(p) {

            //  Path to local versions file
            var versionFile = '/etc/wigwag/versions.json';
            app = express();

            app.get('/test', function(req, res){
                req.socket.on("error", function() {
                    log.error("wwupgradeApp Error in test");
                    log.error("   - Error Code: ", err.code);
                });
                res.json(localVersions);
            });

            app.get('/init', function(req, res){
                req.socket.on("error", function(err) {
                    log.error("Upgrade Service Initialization Failed");
                    log.error("   - Error Code: ", err.code);
                });
                console.log(cloudVersions);
                res.json(upgradeUtils.init(versionFile, versCallback));
            });

            app.get('/whichPackagesNeedUpgrade', function(req, res){
                req.socket.on("error", function() {
                    log.error("WWUpgradeApp - Error in which PackagesNeedUpgrade");
                    log.error("   - Error Code: ", err.code);
                });
                res.json(upgradeUtils.whichPackagesNeedUpgrade(localVersions,cloudVersions));
            });

            app.get('/isUpgradeRequired', function(req, res){
                req.socket.on("error", function() {
                    log.error("WWUpgradeApp - Error in which isUpgradeRequired");
                    log.error("   - Error Code: ", err.code);
                });
                var needUpgrade = upgradeUtils.isUpgradeRequired(localVersions,cloudVersions);
                var retValue = needUpgrade ? "true" : "false";
                res.json(retValue);
            });

            app.get('/logPackage', function(req, res){
                req.socket.on("error", function() {
                    log.error("WWUpgradeApp - Error in which isUpgradeRequired");
                    log.error("   - Error Code: ", err.code);
                });
                console.log(cloudVersions);
            });


            var versCallback = function(a, b) {
                 localVersions = a;
                 cloudVersions = b;
	    };

           upgradeUtils.init(versionFile, versCallback);

           var server = app.listen(configuration.httpPort, function () {
              var host = server.address().address;
              var port = server.address().port;
              console.log('WWUpgradAp listening at http://%s:%s', host, port);
           });

        });
    };

    this.stop = function() {
        return new dev$Promise().when(function(p) {
            p.resolve();
        });
    };
});

module.exports = WWUpgradeApp;
