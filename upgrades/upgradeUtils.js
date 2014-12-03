// DeviceJS
// (c) WigWag Inc 2014

/**
   Utility module to expose the current version of each package/modules
   installed on the WigWag relay
**/

var fs           = require('fs');
var path         = require('path');
var _            = require('underscore');
var md5          = require('MD5');
var http         = require('http');
var events       = require('events');
var JSONminify   = require('./json.minify.js');
var EventEmitter = require('events').EventEmitter;

var versionsObject;
var cloudVersions;
var ee = new EventEmitter();

var numSpaces = function(n) {
    theSpaces = "";
    for (var i=0; i< n*1; i++) {
        theSpaces += ' ';
    }
    return theSpaces;
};
/**
 Determines if the package with the name 'value'
 Exists in the package json "verObj"
**/
var existsPackage = function(verObj, value) {
    if (verObj && value) {
        for (var i=0; i<verObj.packages.length; i++) {
            var tmpObj = verObj.packages[i];
            if (tmpObj.name === value) {
                return true;
            }
        }
    }
    return false;
};

/**
 Returns the index into the vObj of packaged named 'name'
**/
var indexOfPackage = function(vObj, name) {
    for (var i=0; i< vObj.packages.length; i++) {
        if (vObj.packages[i].name === name) {
            return i;
        }
    }
    return -1;
};

/**
 Parses a 3 digit version number and compares them
 Returns true of ver2 is greater than ver1
**/
var isVersionGreater = function(ver1, ver2) {

    vArray1 = ver1.split('.');
    vArray2 = ver2.split('.');

    if (parseInt(vArray1[0]) > parseInt(vArray2[0])) {
        return true;
    } else if (parseInt(vArray1[1]) > parseInt(vArray2[1])) {
        return true;
    } else if (parseInt(vArray1[2]) > parseInt(vArray2[2])) {
        return true;
    } else {
        return false;
    }
};

/**
 Returns and array of the packages that need to be upgraded
 based on the package versions and the md5 has on each of the
 package.json files
**/
var whichPackagesNeedUpgrade = function(local, cloud) {
    var requiresUpgrade = [];
    for (var i=0; i<local.packages.length; i++) {
        cloudIndex = indexOfPackage(cloud, local.packages[i].name);

        if (cloudIndex !== -1) {
            if ((isVersionGreater(cloud.packages[cloudIndex].version,
                                 local.packages[i].version)) ||
                cloud.packages[cloudIndex].node_hash !==
                                 local.packages[i].node_hash || 
                cloud.packages[cloudIndex].ww_module_hash !==
                                 local.packages[i].ww_module_hash) {
                requiresUpgrade[requiresUpgrade.length] = local.packages[i];
            }
        }
    }
    return requiresUpgrade;
};

/**
   Method to walk the package objects and print the attributes
**/
var walkObj = function(zObj) {
    var identLevel = 2;    
    _.each(zObj, function(value, key){
        if (_.isObject(value)) {
            identLevel++;
            if( ! _.isArray(key)) {
                process.stdout.write(numSpaces(identLevel) + key + ": \n");
            }
	    walkObj(value);
            identLevel--;
        } else {
            process.stdout.write(numSpaces(identLevel) + key + ": ");
            process.stdout.write(value + '\n');
        }
    });
};

/**
   Method to pull the versions file from the "cloud"
**/
var getCloudVersions = function() {
    var options = {
        host: 'localhost',
        path: '/api/versions',
        port: '8080'
    };

    var req = http.get(options, function(res) {
        // Buffer the body entirely for processing as a whole.
        var bodyChunks = [];
        res.on('data', function(chunk) {
            bodyChunks.push(chunk);
        }).on('end', function() {
            var body = Buffer.concat(bodyChunks);
            cloudVersions = JSON.parse(body);
            ee.emit("versionsInit", versionsObject, cloudVersions);
        });
    }).on('error', function(e) {
        console.log('ERROR: ' + e.message);
    });
};

module.exports = {

    /**
       Verifies the existence of the versions file and reads it into memory
    **/
    init:  function(path, cb) { 
        if (fs.existsSync(path)) {
            var fContents = fs.readFileSync(path, 'utf8');
            versionsObject = JSON.parse(JSONminify(fContents));
        }
        ee.on("versionsInit", cb);
        getCloudVersions();
        return versionsObject;
    },

    /**
       Method to print the contents of the version file
    **/
    printPackage:  function(zObj) {
        walkObj(zObj);
    },
    availPackages: function() {
        return cloudVersions;
    }, 
    upgradePackages: function() {
    },
    downloadPackages: function() {
        console.log("Needs to be implemented");
    },
    isUpgradeRequired: function (a, b) {
        // Check the version number of the version file 
        // if the version file has not changed, upgrade is not required
        if (isVersionGreater(b.version, a.version) === true){
            return true;
        }
        // Determine which, if any, packages should be upgraded
        var needsUpgrade = whichPackagesNeedUpgrade(a, b);
        if (needsUpgrade.length > 0) {
            return true;
        }
        return false;
    },
    addPackage:    function(name, version, desc, node_module_path, ww_module_path){

        if (versionsObject && version  && name && desc) {
            var nodeMD5 = 0;
            var wwMD5 = 0;

            if (node_module_path && fs.existsSync(node_module_path)) {
                var nodeBuf = fs.readFileSync(node_module_path);
                nodeMD5 = md5(nodeBuf);
            }

            if (ww_module_path && fs.existsSync(ww_module_path)) {
                var wwBuf = fs.readFileSync(ww_module_path);
                wwMD5 = md5(wwBuf);
            }

            newObj = {
                "name" : name,
                "description" : desc,
                "version" : version,
                "node_modules_path" : node_module_path,
                "node_hash" : nodeMD5,
                "ww_module_path" : ww_module_path,
                "ww_module_hash" :  wwMD5
            };
        } else {
            return undefined;
        }
        if (existsPackage(versionsObject, name) === false) {
            versionsObject.packages[versionsObject.packages.length] = newObj;
            return true;
        } else {
            return false;
        }
        
    },
    removePackage: function(value){
        if (versionsObject && value) {
            for (var i=0; i<versionsObject.packages.length; i++) {
                var tmpObj = versionsObject.packages[i];
                if (tmpObj.name === value) {
                    versionsObject.packages.splice(i, 1);
                    return;
                }
            }
        }
    },
    updatePackageVersion: function(name, value){
        if (versionsObject && value) {
            for (var i=0; i<versionsObject.packages.length; i++) {
                var tmpObj = versionsObject.packages[i];
                if (tmpObj.name === name) {
                    versionsObject.packages[i].version = value;
                    return;
                }
            }
        }
    },
    save:   function(path){
        if (versionsObject && path) {
            fs.writeFileSync(path, JSON.stringify(versionsObject, null, 4), "UTF-8",{'flags': 'w+'});
        }
    }
};
