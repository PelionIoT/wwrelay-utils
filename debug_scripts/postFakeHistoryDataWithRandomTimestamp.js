var request = require('request');
var fs = require('fs');
var state1 = 'on'
sslKey = fs.readFileSync("/wigwag/devicejs-core-modules/Runner/.ssl/client.key.pem", 'utf8');
sslCert = fs.readFileSync("/wigwag/devicejs-core-modules/Runner/.ssl/client.cert.pem", 'utf8');

var timestamp = Date.now() - 2592000000

function newRequestOptions(options) {
    if(typeof options === 'object') {
        options.key = sslKey;
        options.cert = sslCert;
        // options.ca = self.sslCa;
        // options.agentOptions = {
        //     rejectUnauthorized: false,
        //     checkServerIdentity: function() {
        //     }
        // }
    } else {
        log.error('Options is not of type object');
    }
    return options;
}

function postData(state, timestamp) {
    return new Promise(function(resolve, reject) {
        request( newRequestOptions({
            headers: {
                "Content-Type": "application/json",
                "X-WigWag-RelayID": "WDRL00000P",
                "X-WigWag-Identity": {
                    "clientType": "relay",
                    "relayID":"WDRL00000P",
                    "accountID":"e20b161cdf7f41c6b38b4c45940097f9",
                    "siteID":"3d5cb8ac8f3f40829d9ad1c6324f7fb3"
                }
            },
            uri: "https://dev-relays.wigwag.io/relay-history/history",
            method: 'POST',
            json: true,
            body: [{
                timestamp: timestamp,
                device: "VirtualLightBulb61",
                event: "state-power",
                metadata: state
            }]
        }), function(error, response, responseBody) {
            if(error) {
                reject(error);
            }
            else if(response.statusCode == 200) {
                resolve(responseBody);
            }
            else {
                reject({ status: response.statusCode, msg: response.statusMessage, response: responseBody });
            }
        });
    });
}

setInterval(function() {
    var reduceMS = Math.floor(1000000 + Math.random() * 9000000)
    timestamp = timestamp - reduceMS
    var state = reduceMS > 3000000 ? "on" : "off"
    postData(state, timestamp).then(function() {
        console.log('Events genrated - ' + state + ' for '+ timestamp + ' timestamp success!');
      //  process.exit(0);
    }, function(err) {
        console.error('Failed ', err);
    });
}, 1000)


