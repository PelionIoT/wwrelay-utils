const scanner = require('local-network-scanner');
var fs = require('fs')
fs.truncate('./samplelist', 0, function(){console.log('')})
var file ='./samplelist'

var fd = fs.openSync(file, 'a')

var wstream = fs.createWriteStream(file, {
        fd: fd
    });
    wstream.on('error', function(err) {
        throw err;
})

//var stat = fs.statSync(file);
//fs.truncate('./samplelist', 0, function(){console.log('done')})

scanner.scan(devices => {
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