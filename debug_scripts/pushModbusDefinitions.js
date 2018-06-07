var fs = require('fs');
var jsonminify = require('jsonminify');
var dcMetaData = fs.readFileSync('/config/GiantIMod6Configphotocellmodreduced.json', 'utf8')
dev$.selectByID('ModbusDriver').call('start', JSON.parse(jsonminify(dcMetaData)));