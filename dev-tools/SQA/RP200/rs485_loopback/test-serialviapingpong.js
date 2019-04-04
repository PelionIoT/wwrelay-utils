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
    console.log('Run this in server mode on one box and in client mode on another.');
    console.log('\nUsage- node test-serialviapingpong.js [serialport=/dev/ttyUSB0] [baudrate=115200] [mode=server or client]\n');
    process.exit(1);
}

var serialComm = new SerialComm({
    siodev: process.argv[2] || "/dev/ttyUSB0",
    baudrate: process.argv[3] || 115200
});

var mode = process.argv[4] || 'server';

var bar = new ProgressBar('Progress [:bar] :rate/bps :percent :etas', { total: 128 });

var input = new Buffer([0x00]);
var sendNext = true;
var i = 0;
var responseTimer;
var clientConnected = false;
var serialTransmitTimer, clientWaitTimer;
var startTime;

var clienttimeout, servertimeout;
serialComm.start().then(function() {
    if(mode !== 'server') {
        process.stdout.write('Receiving... ');
        clienttimeout = setTimeout(function() {
            console.error('Failed to receive something. exiting...');
        }, 15000);
    }
    serialComm.on('data', function(output) {
        clearTimeout(clienttimeout);
        // console.log('Input is ', input);
        if(mode == 'server') {
            if(input[0] == output[0]) {
                clearInterval (clientWaitTimer);
                if(!clientConnected) {
                    startTime = new Date();
                }
                clientConnected = true;
                if((i++ % 2) === 0) {
                    bar.tick();
                }
                if(output[0] === 255) {
                    var completeTime = new Date();
                    console.log('\nLoopback test completed successfully in time ' + (completeTime - startTime )+ 'msec\n');
                    //Terminate sequence
                    serialComm.write([0x55, 0xFF]);
                    clearInterval(serialTransmitTimer);
                    process.exit(0);
                } else {
                    input[0]++;
                    sendNext = true;
                    clearTimeout(responseTimer);
                    sendNextByte();
                }
            } else {
                console.error('\n\nError, Got unexpected output, output- ' + output[0] + ' input- ' + input[0] + '\n');
                process.exit(1);
            }
        } else {
            // console.log('Received- ', output);
            process.stdout.write('.');
            if(output[0] == 0x55 && output[1] == 0xFF) {
                console.log('Successfully completed!');
                process.exit(0);
            }
            // process.stdout.write(output.toString('hex'));
            serialComm.write([output[0]]);
        }
    });

    if(mode == 'server') {
        console.log('Sending data from 0 to 255...');
        function sendNextByte() {
            if(sendNext) {
                // console.log('sending ', input);
                serialComm.write([input[0]]);
                sendNext = false;
                if(clientConnected) {
                    clearTimeout(responseTimer);
                    responseTimer = setTimeout(function() {
                        console.error('\n\nFailed to get response for input '+ input[0] + '\n');
                        process.exit(1);
                    }, 100);
                } else {
                    console.log('Waiting for client to connect...');
                    clientWaitTimer = setInterval(function() {
                        console.log('Waiting...');
                        servertimeout = setTimeout(function() {
                            console.error('Failed to connect with client. exiting...');
                            process.exit(1);
                        }, 10000);
                        if(clientConnected) {
                            clearTimeout(servertimeout);
                            clearInterval (clientWaitTimer);
                        }
                    }, 500);
                }
            }
        } 
        sendNextByte();
    }
}, function(err) {
    console.error('Failed with error ', err);
});
