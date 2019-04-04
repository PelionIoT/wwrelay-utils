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


let createVirtualDevices = () => {
	return new Promise(function(resolve, reject) {
		dev$.selectByID('VirtualDeviceDriver').call('listTemplates').then(function(templateResp, err) {
			if(templateResp.VirtualDeviceDriver.response.result) {
				console.log('Starting creating new virtual device')
				let templates = templateResp.VirtualDeviceDriver.response.result;
				var startDevices = async () => {
                    try {
                        for(var i = 0; i < templates.length; i++) {
                            console.log('Creating virtual device of type ' + templates[i]);
                            await dev$.selectByID('VirtualDeviceDriver').call('create', templates[i]).then(function(resp) {
							    console.log(resp.VirtualDeviceDriver.response.result);
							});
                            // await DCS.executeCommand(program.site, "id=\"VirtualDeviceDriver\"", "create", templates[i]).then(function(rsp) {
                            //     console.log(rsp);
                            // });
                        } 
                    }catch(err) {
                        reject(err);
                    } finally {
                        resolve();
                    }
                }
                startDevices();
			}else {
				return reject('Failed to list virtual device template list');
			}	
		})
	})
}

createVirtualDevices()