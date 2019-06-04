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

var currentlyRaised = false;

function raiseAlert(id, luminance) {
    dev$.alert('Too dark', 'warning', true, { 
        luminance: luminance,
        id: id
    });
    currentlyRaised = true;
    log.info(id + ' Too dark, alert raised!!');
}

function lowerAlert(id, luminance) {
    dev$.alert('Too dark', 'warning', false, {
        luminance: luminance,
        id: id
    });
    currentlyRaised = false;
    log.info(id + ' Too dark, alert lowered!!');
}

function checkAlertCondition(id, luminance) {
    if(luminance < 60 && !currentlyRaised) {
        raiseAlert(id, luminance);
    } else if(luminance > 60 && currentlyRaised) {
        lowerAlert(id, luminance);
    }
}

var allStates = dev$.select('id=*');
allStates.subscribeToState('+');
allStates.on('state', function(id, type, data) {
    if(type === 'luminance') {
        log.info(id + ' luminance level ' + data);
        checkAlertCondition(id, data);
    }
});

var allEvents = dev$.select('id=*');
allEvents.subscribeToEvent('+');
allEvents.on('event', function(id, type, data) {
    if(type === 'luminance') {
        log.info(id + ' luminance level ' + data);
        checkAlertCondition(id, data);
    }
});