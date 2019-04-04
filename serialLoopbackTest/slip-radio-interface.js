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

var SerialComm = require('./l1-serialCommInterface');

if(typeof process.argv[2] !== 'undefined' && process.argv[2].indexOf('-h') > -1) {
    console.log('Place serial line in loopback- connect RX to TX and run this test to verify the serial connection!');
    console.log('\nUsage- node test-serialLoopback.js [serialport] [baudrate]\n');
    process.exit(0);
}

var serialComm = new SerialComm({
    siodev: process.argv[2] || "/dev/ttyUSB0",
    baudrate: process.argv[3] || 115200
});

var input = new Buffer('?C');
serialComm.start().then(function() {
    serialComm.on('data', function(output) {
        console.log('Received- ', output);
    });

    console.log('Writing input ', input);
    serialComm.write([0x3F, 0x50]);
}, function(err) {
    console.error('Failed with error ', err);
});
