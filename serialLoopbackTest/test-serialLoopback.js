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
var ProgressBar = require('progress');

if(typeof process.argv[2] !== 'undefined' && process.argv[2].indexOf('-h') > -1) {
    console.log('Place serial line in loopback- connect RX to TX and run this test to verify the serial connection!');
    console.log('\nUsage- node test-serialLoopback.js [serialport] [baudrate]\n');
    process.exit(0);
}

var serialComm = new SerialComm({
    siodev: process.argv[2] || "/dev/ttyUSB0",
    baudrate: process.argv[3] || 115200
});

var bar = new ProgressBar('Progress [:bar] :rate/bps :percent :etas', { total: 128 });

var input = new Buffer([0x00]);
var sendNext = true;
var i = 0;
var responseTimer;
serialComm.start().then(function() {
    serialComm.on('data', function(output) {
        // console.log('Received- ', output);
        // console.log('Input is ', input);
        if(input[0] == output[0]) {
            if((i++ % 2) === 0) {
                bar.tick();
            }
            if(output[0] === 255) {
                console.log('\nLoopback test completed successfully!\n');
                clearInterval(timer);
                process.exit(0);
            } else {
                input[0]++;
                sendNext = true;
                clearTimeout(responseTimer);
            }
        } else {
            console.error('\n\nError, Got unexpected output, output- ' + output[0] + ' input- ' + input[0] + '\n');
            process.exit(1);
        }
    });

    console.log('Sending data from 0 to 255...');
    var timer = setInterval(function () {
        if(sendNext) {
            // console.log('sending ', input);
            serialComm.write([input[0]]);
            sendNext = false;
            clearTimeout(responseTimer);
            responseTimer = setTimeout(function() {
                console.error('\n\nFailed to get response for input '+ input[0] + '\n');
                process.exit(1);
            }, 100);
        }
    }, 25);
}, function(err) {
    console.error('Failed with error ', err);
});
