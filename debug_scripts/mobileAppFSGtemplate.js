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

var templateModbus = function() {
    return new Promise(function(resolve, reject) {
        console.log('Creating Softoverride location...');
        dev$.createResourceGroup('Softoverride').then(function() {
            console.log('\tSuccessfully created Softoverride location');
            console.log('Moving Modbus devices to Softoverride location...');
            dev$.select('id=*').listResources().then(function(a) { 
                var p = [];
                var devices = [];
                Object.keys(a).forEach(function(b) { 
                    if(a[b].type.indexOf('Core/Devices/ModbusRTU/IMod6') > -1) { 
                        devices.push(b);
                        p.push(dev$.joinResourceGroup(b, 'Softoverride'));
                    }
                });

                Promise.all(p).then(function() {
                    console.log('\tSuccessfully moved all Modbus devices to Softoverride location');
                    resolve(devices);
                }, function(err) {
                    console.error('\tFailed to move modbus devices to Softoverride location');
                    reject(err);
                });
            });
        });
    });
};

var templateThermostats = function() {
    return new Promise(function(resolve, reject) {
        console.log('Creating Tstats location...');
        dev$.createResourceGroup('Tstats').then(function() {
            console.log('\tSuccessfully created Tstats location');
            console.log('Moving Thermostats to Tstats location...');
            var p = [];
            var devices = [];
            dev$.selectByInterface('Facades/ThermostatMode').listResources().then(function(a) { 
                Object.keys(a).forEach(function(b) { 
                    devices.push(b);
                    p.push(dev$.joinResourceGroup(b, 'Tstats'));
                });

                Promise.all(p).then(function() {
                    console.log('\tSuccessfully moved all Thermostats to Tstats location');
                    resolve(devices);
                }, function(err) {
                    console.error('\tFailed to move Thermostats to Tstats location');
                    reject(err);
                });
            });
        });
    });
};

var verifyLocations = function() {
    return new Promise(function(resolve, reject) {
        return dev$.getResourceGroup().then(function(resp) {
            console.log('Locations - ', Object.keys(resp.children));
            resolve();
        });
    });
};

var verifyModbus = function() {
    return new Promise(function(resolve, reject) {
        return dev$.getResourceGroup().then(function(resp) {
            if(typeof resp.children.Softoverride === 'undefined') {
                console.error('Failed to read Softoverride location');
                return reject();
            }
            console.log('\nDevices in Softoverride location- ', Object.keys(resp.children.Softoverride.resources));
            resolve();
        });
    });
};

var verifyThermostat = function() {
    return new Promise(function(resolve, reject) {
        return dev$.getResourceGroup().then(function(resp) {
            if(typeof resp.children.Tstats === 'undefined') {
                console.error('Failed to read Tstats location');
                return reject();
            }
            console.log('\nDevices in Tstats location- ', Object.keys(resp.children.Tstats.resources));
            resolve();
        });
    });
};

var addToDashboard = function(deviceList) {
    return new Promise(function(resolve, reject) {
        var appDataPrefix = 'WigWagUI:appData.';
        console.log('Adding to dashboard... ' + JSON.stringify(deviceList));
        ddb.shared.put(appDataPrefix + '.dashboard', JSON.stringify(deviceList)).then(function() {
            console.log('\tSuccessfully added to dashboard');
            resolve();
        }, function(err) {
            console.error('\tFailed to add to dashboard ', err);
            reject(err);
        });
    });
};

var verifyDashboard = function() {
    return new Promise(function(resolve, reject) {
        var appDataPrefix = 'WigWagUI:appData.';
        ddb.shared.get(appDataPrefix + '.dashboard').then(function(d) {
            var list = (d && d.siblings) ? d.siblings[0] : null;
            console.log('\nDashboard devices- ', list);
            resolve();
        }, function(err) {
            console.error('Failed to retrieve dashboard devices');
            reject(err);
        });
    });
};

console.log('Starting MobileApp_FSG_CircleK_template...');
templateModbus().then(function(modbusDevices) {
    console.log('\nModbus Complete\n');
    templateThermostats().then(function(thermostats) {
        console.log('\nThermostats Complete\n');
        addToDashboard(thermostats.concat(modbusDevices)).then(function() {
            console.log('\nDashboard Complete\n');

            console.log('\nVerify the template...');
            verifyLocations().then(function() {
                verifyModbus().then(function() {
                    verifyThermostat().then(function() {
                        verifyDashboard().then(function() {
                            console.log('\nMobileApp_FSG_CircleK_template complete... Bye!');
                            process.exit(0);  
                        });
                    });
                });
            });
        }).catch(function(err) {
            console.error('MobileApp_FSG_CircleK_template failed with error ', err);
        });
    }).catch(function(err) {
        console.error('MobileApp_FSG_CircleK_template failed with error ', err);
    });
}).catch(function(err) {
    console.error('MobileApp_FSG_CircleK_template failed with error ', err);
});