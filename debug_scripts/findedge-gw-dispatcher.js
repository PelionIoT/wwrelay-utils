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


