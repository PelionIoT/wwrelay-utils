var SerialComm = require('./l1-serialCommInterface');

if(typeof process.argv[2] !== 'undefined' && process.argv[2].indexOf('-h') > -1) {
    console.log('Place serial line in loopback- connect RX to TX and run this test to verify the serial connection!');
    console.log('\nUsage- node test-serialLoopback.js [serialport] [baudrate]\n');
    process.exit(0);
}

var serialComm = new SerialComm({
    siodev: process.argv[2] || "/dev/ttyUSB0",
    baudrate: process.argv[3] || 115200
});

var mode = process.argv[4] || 'tx';

var input = new Buffer([0x00]);
serialComm.start().then(function() {
    serialComm.on('data', function(output) {
        console.log('Received- ', output);
    });

    if(mode == 'tx') {
        console.log('Sending data from 0 to 255...');
        var timer = setInterval(function () {
            console.log('Writing input ', input);
            serialComm.write([input[0]++]);
        }, 50);
    }
}, function(err) {
    console.error('Failed with error ', err);
});
