'use strict'

const inquirer = require('inquirer')
const uuid = require('uuid')
const crypto = require('crypto')
const execSync = require('child_process').execSync
const fs = require('fs')
const IDGenerator = require('./IDgenerator')
const program = require('commander');


program
	.version('1.0.0')
    .option('-g, --gatewayServicesAddress []', 'The gateway services API address')
    .option('-a, --apiServerAddress []', 'API server address')
    .option('-p, --serialNumberPrefix []', 'Serial Number Prefix')
	.parse(process.argv);

var validHostURI = /^(https\:\/\/)?((?:(?:[a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*(?:[A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9]))$/

function gatewayAddressQuestion(_default) {
    if (!_default || typeof _default == 'string' || _default.length < 0) {
        _default = ''
    }
    let message = 'Enter the gateway services API address?'
    if (_default.length > 0) {
        message += ' ('+_default+')'
    }
    return inquirer.prompt([{
        type: 'input',
        name: 'gatewayServicesAddress',
        message: message,
        validate: function(answer) {
            if(answer.length) {
                var m = validHostURI.exec(answer)
                if (m && m.length > 2) {
                    if (typeof m[1] != 'string' || m[1].length < 1) {
                        answer = 'https://' + m[2]
                    }
                    return true
                }
                // console.log("!!!!!>",answer,'<')
                // let success = false;
                // if (answer.indexOf('http://') > -1) {
                //     success = false;
                // }
                // if (answer.indexOf('http') > -1 && answer.slice(0, 8) !== 'https://') {
                //     success = false;
                // }
                // if (answer.indexOf('https://') > -1) {
                //     answer = answer.slice(8);
                //     success = true
                // }
                // if (answer.split('.').length != 3 || answer.split('.').indexOf('') > -1) {
                //     success = false;
                // }
                // console.log("11111")
                // if(success) {
                // // console.log("22222>",answer,"<<<")
                //     if (/^[a-z]([a-z0-9-.]{0,62}[a-z0-9])?$/.test(answer)) {
                // // console.log("33333")
                //         return true;
                //     }
                // }
                return 'Please enter the gateway services address?'

            } else {
                return 'Please enter the gateway services address?'
            }
        }
    }])
}

function apiAddressQuestion(_default) {
    if (!_default || typeof _default == 'string' || _default.length < 0) {
        _default = ''
    }
    let message = 'Enter API server address?'
    if (_default.length > 0) {
        message += ' ('+_default+')'
    }
    return inquirer.prompt([{
        type: 'input',
        name: 'apiServerAddress',
        message: message,
        validate: function(answer) {
            if(answer.length) {
                var m = validHostURI.exec(answer)
                if (m && m.length > 2) {
                    if (typeof m[1] != 'string' || m[1].length < 1) {
                        answer = 'https://' + m[2]
                    }
                    return true
                }
                // let success = false;
                // if (answer.indexOf('http://') > -1) {
                //     success = false;
                // }
                // if (answer.indexOf('http') > -1 && answer.slice(0, 8) !== 'https://') {
                //     success = false;
                // }
                // if (answer.indexOf('https://') > -1) {
                //     answer = answer.slice(8);
                //     success = true
                // }
                // if (answer.split('.').length != 3 || answer.split('.').indexOf('') > -1) {
                //     success = false;
                // }
                // if(success) {
                //     if (/^[a-z]([a-z0-9-.]{0,62}[a-z0-9])?$/.test(answer)) {
                //         return true;
                //     }
                // }
                return 'Please enter API server address?'
            } else {
                return 'Please enter API server address?'
            }
        }
    }])
}

var addrs = {}

var reGetBaseDomain = /https:\/\/[^\.]+\.(.*)/;

var cleanupURL = function(answer) {
    var m = validHostURI.exec(answer)
    if (m && m.length > 2) {
        if (typeof m[1] != 'string' || m[1].length < 1) {
            answer = 'https://' + m[2]
        }
        return answer
    }    
}

async function confirmAddresses() {

    let ok = {confirmed: false}
    var ret = {}
    while (!ok.confirmed) {
        addrs.apiAddr = await apiAddressQuestion()
        addrs.gwAddr = await gatewayAddressQuestion()
        ret.gatewayServicesAddress = cleanupURL(addrs.gwAddr.gatewayServicesAddress)
        ret.apiServerAddress = cleanupURL(addrs.apiAddr.apiServerAddress)
        console.log("API address: %s\nGateway services API addresss: %s\n",ret.apiServerAddress,ret.gatewayServicesAddress)
        ok = await inquirer.prompt([{
            type: 'confirm',
            name: 'confirmed',
            message: 'Confirm these are the correct addresses.',
            validate: function(answer) {
                console.log("HEY!!!")
                if (answer == 'y' || answer == 'Y') {
                    ok = true
                    return true
                }
            }
        }])
    }
    return ret
}

function generateRandomEUI() {
    return [crypto.randomBytes(1)[0], crypto.randomBytes(1)[0], crypto.randomBytes(1)[0]]
}

const run = async() => {
    let identity_obj = {}

    let currentSerialNumber = crypto.randomBytes(2).readUInt16BE(0, true);
    identity_obj.serialNumber = IDGenerator.SerialIDGenerator(program.serialNumberPrefix || 'SOFT', currentSerialNumber, currentSerialNumber + 1)
    identity_obj.OU = uuid.v4().replace(/-/g, "")
    identity_obj.deviceID = uuid.v4().replace(/-/g, "")
    identity_obj.hardwareVersion = "SOFT_GW"
    identity_obj.radioConfig = "00"
    identity_obj.ledConfig = "01"
    identity_obj.category = "development"
    let eui = generateRandomEUI()
    identity_obj.ethernetMAC = [0, 165, 9].concat(eui)
    identity_obj.sixBMAC = [0, 165, 9, 0, 1].concat(eui)
    identity_obj.hash = [];

    if(!program.gatewayServicesAddress)
        addrs = await confirmAddresses()
    else
        addrs = {
            gatewayServicesAddress: program.gatewayServicesAddress
        }

//    identity_obj = Object.assign({}, identity_obj, await gatewayAddressQuestion(), await apiAddressQuestion())
    identity_obj = Object.assign({}, identity_obj, addrs)
    identity_obj.cloudAddress = identity_obj.gatewayServicesAddress;

    identity_obj.ssl = {}
    execSync('OU=' + identity_obj.OU + ' internalid=' + identity_obj.deviceID + ' ./generate_self_signed_certs.sh')
    const device_key = fs.readFileSync('./temp_certs/device_private_key.pem', 'utf8')
	const device_cert = fs.readFileSync('./temp_certs/device_cert.pem', 'utf8')
	const root_cert = fs.readFileSync('./temp_certs/root_cert.pem', 'utf8')
	const intermediate_cert = fs.readFileSync('./temp_certs/intermediate_cert.pem', 'utf8')

    identity_obj.ssl.client = {}
    identity_obj.ssl.client.key = device_key
    identity_obj.ssl.client.certificate = device_cert

    identity_obj.ssl.server = {}
	identity_obj.ssl.server.key = device_key
    identity_obj.ssl.server.certificate = device_cert

    identity_obj.ssl.ca = {}
	identity_obj.ssl.ca.ca = root_cert
    identity_obj.ssl.ca.intermediate = intermediate_cert

    execSync('rm -rf ./temp_certs')

    console.log('Writing developer identity file with serialNumber=%s, identity.json', identity_obj.serialNumber)
    fs.writeFileSync('./identity.json', JSON.stringify(identity_obj, null, 4), 'utf8')
    console.log('Success. Bye!')
}

run()
