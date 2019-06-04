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

var allEvents = dev$.select('id=*');
allEvents.subscribeToEvent('+');
allEvents.on('event', function(id, type, data) {  console.log('Event- Device ' + id + ' type ' + type + ' data ' + JSON.stringify(data)); });

var allStates = dev$.select('id=*');
allStates.subscribeToState('+');
allStates.on('state', function(id, type, data) { console.log('State- Device ' + id + ' type ' + type + ' data ' + JSON.stringify(data)); });

var allDiscover = dev$.select('id=*');
allDiscover.subscribeToEvent('discovery');
allDiscover.on('event', function(id, type, data) { console.log('Discovery- Device ' + id + ' type ' + type + ' data ' + JSON.stringify(data)); });