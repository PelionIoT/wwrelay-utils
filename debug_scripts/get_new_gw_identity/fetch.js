'use strict'
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

var bonjour = require('bonjour')()
var chalk = require('chalk')
const fs = require('fs');
var exec = require('child_process').exec

var fetching = function (file) {
    process.argv[2] = file
    return new Promise(function (resolve, reject) {
        var findip = function () {
            return new Promise(function (resolve, reject) {
                console.log(chalk.blue("Looking for Gateway-dispatcher.........................\n"))
                var check = 0
                function ask() {
                    if (check == 0) {
                        function asktowait(arg) {
                            console.log(`${arg}`);
                        }
                        setTimeout(asktowait, 500, 'Please wait still looking for Gateway-dispatcher.......');

                        function asktorestart(arg) {
                            console.log(`${arg}`);
                        }
                        setTimeout(asktorestart, 30000, 'Please restart your Gateway-dispatcher.................');
                    }
                }
                setTimeout(ask, 30000);
                bonjour.findOne({
                    type: 'Local-Network',
                }, function (service) {
                    check = 1;
                    console.log('Found gateway-dispatcher having IP:', service.referer.address)
                    resolve(service.referer.address);
                })
            })
        }

        if (!process.argv[2]) {
            console.log("Please enter the configuration file");
            reject("Please enter the configuration file")
            process.exit(1);
        } else {
            var file = process.argv[2]
            if (!fs.existsSync(file)) {
                console.log(chalk.bold("Configuration File- " + file + " does not exist!"));
                reject("Configuration File- " + file + " does not exist!")
                process.exit(1);
            } else {
                if (file.split('.').pop() === 'json') {
                    findip().then(function (result) {
                        var child = exec('/wigwag/wwrelay-utils/debug_scripts/get_new_gw_identity/fetcheeprom.sh' + " " + file + " " + result, function (err, stdout, stderr) {
                            if (err != null) {
                                console.log(err)
                                process.exit(1);
                            } else {
                                console.log(stdout)
                            }
                        });
                        child.stdout.on('data', function (data) {
                            console.log(data);
                            if (data == 'No match Found in the database') {
                                process.exit(0)
                            }
                        })
                        child.stderr.on('data', function (data) {
                            console.log(data);
                        })
                        child.on('close', function (data) {
                            console.log(data);
                            resolve("Shell script ran successfully")
                            process.exit(0);
                        })
                    })
                } else {
                    console.error(chalk.bold("Please enter the file having json extension"));
                    reject("Please enter the file having json extension");
                    process.exit(1);
                }

            }
        }
    })
}
fetching(process.argv[2]);
module.exports = {
    fetching
}
