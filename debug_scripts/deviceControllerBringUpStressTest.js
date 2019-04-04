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

dev$.selectByID('VirtualDeviceDriver').call('deleteAll');
for(var i = 0; i < 20; i++) {
    dev$.selectByID('VirtualDeviceDriver').call('create', 'ContactSensor').then(function(resp) {
        console.log('Started controller ', resp);
    }, function(err) {
        console.error('Failed to start deviceController ' + err +  '  ' + JSON.stringify(err));
    });
}