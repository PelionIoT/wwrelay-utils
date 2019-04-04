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

'use strict'
var bonjour = require('bonjour')()
const fs = require('fs');
const chalk = require('chalk');
const shell = require('shelljs')
var fetchingprogram=require('/wigwag/wwrelay-utils/debug_scripts/tools/fetch.js');
fetchingprogram.fetching(process.argv[2]).then(function(result){
    console.log(result);
}, function(err){
    console.log(chalk.bold("Error: ",err))
})


