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
const fs = require('fs');
const chalk = require('chalk');
var fetchingprogram = require('/wigwag/wwrelay-utils/debug_scripts/tools/fetch.js');
fetchingprogram.fetching(process.argv[2]).then(function(result){
    console.log(result);
}, function(err){
    console.log(chalk.bold("Error: ",err))
})


/*var findip = function() {
    return new Promise(function(resolve, reject) {
        console.log(chalk.blue("Looking for Gateway-dispatcher.........................\n"))
        bonjour.findOne({
            type: 'Local',
            timeout: 1500
        }, function(service) {
            console.log('Found gateway-dispatcher having IP:', service.referer.address)
            resolve(service.referer.address);
        })
    })
}


if (!process.argv[2]) {
    console.log("Please enter the configuration file");
    process.exit(1);
} else {
    var file = process.argv[2]
    if (!fs.existsSync(file)) {
        console.log(chalk.bold("Configuration File- " + file + " does not exist!"));
        process.exit(1);
    } else {
        if (file.split('.').pop() === 'json') {
            findip().then(function(result) {
                shell.exec('./fetcheeprom.sh' + " " + file + " " + result, function(err, result) {
                    if (err) {
                        console.log(chalk.bold("Error occured while executing the shell script: " + err))
                        process.exit(1);
                    } else {
                        console.log(chalk.bold("Shell script ran successfully "));
                        process.exit(0);
                    }
                });
            })
        } else {
            console.error(chalk.bold("Please enter the file having json extension"));
            process.exit(1);
        }

    }
}*/
