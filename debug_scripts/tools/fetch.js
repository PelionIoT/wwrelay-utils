'use strict'
var bonjour = require('bonjour')()
const fs = require('fs');
const chalk = require('chalk');
const shell = require('shelljs')


var fetching = function(file) {
    process.argv[2] = file
    return new Promise(function(resolve, reject) {
        var findip = function() {
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
            reject("Please enter the configuration file")
            //process.exit(1);
        } else {
            var file = process.argv[2]
            if (!fs.existsSync(file)) {
                console.log(chalk.bold("Configuration File- " + file + " does not exist!"));
                reject("Configuration File- " + file + " does not exist!")
                //process.exit(1);
            } else {
                if (file.split('.').pop() === 'json') {
                    findip().then(function(result) {
                        shell.exec('/wigwag/wwrelay-utils/debug_scripts/tools/fetcheeprom.sh' + " " + file + " " + result, function(err, result) {
                            if (err) {
                                console.log(chalk.bold("Error occured while executing the shell script: " + err))
                                reject("Error occured while executing the shell script: " + err)
                                //process.exit(1);
                            } else {
                                console.log(chalk.bold("Shell script ran successfully "));
                                resolve("Shell script ran successfully")
                                //process.exit(0);
                            }
                        });
                    })
                } else {
                    console.error(chalk.bold("Please enter the file having json extension"));
                    reject("Please enter the file having json extension");
                    //process.exit(1);
                }

            }
        }
    })       
}
module.exports =  {fetching}
