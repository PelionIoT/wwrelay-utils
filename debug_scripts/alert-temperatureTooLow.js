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

var resourceID;

function startApp() {
    var temperature;
    var currentlyRaised = false;

    function raiseAlert() {
        dev$.alert('Temperature Too Low', 'warning', true, { 
            temp: temperature 
        });
        currentlyRaised = true;
        log.info('Temperature Too Low, alert raised!!');
    }

    function lowerAlert() {
        dev$.alert('Temperature Too Low', 'warning', false, {
            temp: temperature
        });
        currentlyRaised = false;
        log.info('Temperature Too Low, alert lowered!!');
    }

    function checkAlertCondition() {
        if(temperature < 65 && !currentlyRaised) {
            raiseAlert();
        } else if(temperature > 65 && currentlyRaised) {
            lowerAlert();
        }
    }

    var allStates = dev$.selectByID(resourceID);
    allStates.subscribeToState('+');
    allStates.on('state', function(id, type, data) { 
        if(id == resourceID) {
            temperature = data;
            log.info('Got temperature state from ' + resourceID + ' data ' + temperature);
            checkAlertCondition();
        }
    });

    var allEvents = dev$.selectByID(resourceID);
    allEvents.subscribeToEvent('+');
    allEvents.on('event', function(id, type, data) {
        if(id == resourceID) {
            temperature = data;
            log.info('Got temperature event from ' + resourceID + ' data ' + temperature);
            checkAlertCondition();
        }
    });

    setInterval(function() {
        dev$.selectByID(resourceID).get('temperature').then(function(resp) {
            if(resp && resp[resourceID] && resp[resourceID].response && resp[resourceID].response.result) {
                if(typeof resp[resourceID].response.result === 'number') {
                    temperature = resp[resourceID].response.result;
                    log.info('Got temperature from ' + resourceID + ' data ' + temperature);
                    checkAlertCondition();
                }
            }
        });
    }, 5000);


    setInterval(function() {
        dev$.selectByID(resourceID).call('emit');
    }, 1000);
}

function getTemperatureSensor() {
    //Find temperature resource type resourceId
    dev$.select('id=*').listResources().then(function(resources) {
        var found = false;
        Object.keys(resources).forEach(function(resrc) {
            if(resources[resrc].type == "Core/Devices/Virtual/Temperature") {
                found = true;
                resourceID = resrc;
            }
        });

        if(found) {
            startApp();
        } else {
            //Create temperature sensor
            dev$.selectByID('VirtualDeviceDriver').call('create', 'Temperature').then(function(resp) {
                if(resp && resp.VirtualDeviceDriver && resp.VirtualDeviceDriver.response && resp.VirtualDeviceDriver.response.result) {
                    log.info(resp.VirtualDeviceDriver.response.result);
                    getTemperatureSensor();
                } else {
                    log.error('Failed to create temperature sensor ' + JSON.stringify(resp));
                }
            }, function(err) {
                log.error('Failed to create temperature sensor ' + err);
            });
        }
    });
}

getTemperatureSensor();