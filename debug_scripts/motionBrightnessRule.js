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

var allEvents = dev$.selectByID("ZW010f200108013");
allEvents.subscribeToEvent('+');
allEvents.on('event', function(id, type, data) {
    if(id == 'ZW010f200108013' && type == 'motion' && data === true) {
        dev$.selectByID('AD_HOC_ELECTRONICS_04019f5a').set('brightness', 0.5);
    }
});