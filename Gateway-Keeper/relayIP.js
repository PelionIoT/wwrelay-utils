// const sudo = require('sudo');
var fs = require('fs');
var exec = require('child_process').exec;
fs.truncate('./samplelist', 0, function(){ console.log(''); });
var file ='./samplelist';

var fd = fs.openSync(file, 'a');

var wstream = fs.createWriteStream(file, {
        fd: fd
    });
    wstream.on('error', function(err) {
        throw err;
});

const IP_INDEX = 0;
const MAC_ADDRESS_INDEX = 1;

var IP = {};
scan = callback => {
    console.log('Start scanning network');

    const arpCommand = 'arp-scan -l -q';
    let bufferStream = '';
    let errorStream = '';

    var child = exec(arpCommand, function(error, stdout, stderr) {
        if (error !== null) {
            console.error('Failed ', error);
        }
    });

    child.stdout.on('data', data => {
        bufferStream += data;
    });

    child.stderr.on('data', error => {
        errorStream += error;
    });

    child.on('close', code => {
        console.log('Scan finished');

        if (code !== 0) {
            console.log('Error: ' + code + ' : ' + errorStream);
            return;
        }

        const rows = bufferStream.split('\n');
        const devices = [];

        for (let i = 2; i < rows.length - 4; i++) {
            const cells = rows[i].split('\t').filter(String);
            const device = {};

            if (cells[IP_INDEX]) {
                device.ip = cells[IP_INDEX];
            }

            if (cells[MAC_ADDRESS_INDEX]) {
                device.mac = cells[MAC_ADDRESS_INDEX];
            }

            devices.push(device);
        }

        callback(devices);
    });
};

scan(devices => {
    //fs.truncate('./samplelist', 0, function(){console.log('')})
    devices.forEach((device) => {
        if(device.mac.indexOf('00:a5:09') > -1) {
            wstream.write(device.ip + '\n');
            //fs.writeFile('./samplelist', device.ip, function(){console.log('new Ip added')})
            //process.exit()
            console.log(device.ip)
            return device.ip
        }
    })
    //console.log(devices);
},function(err) {
    console.log(err)
});