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

var input = new Buffer('?C');
serialComm.start().then(function() {
    serialComm.on('data', function(output) {
        console.log('Received- ', output);
    });

    console.log('Writing input ', input);
    serialComm.write([0x3F, 0x50]);
}, function(err) {
    console.error('Failed with error ', err);
});
