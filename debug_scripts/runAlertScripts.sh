#!/bin/bash
kill `ps -ef | grep alert- | awk '{print $2}'`
sleep 2
echo 'Starting alert-tooDark'
/wigwag/devicejs-ng/bin/devicejs run ./alert-tooDark.js --config=/wigwag/etc/devicejs/devicejs.conf >& tooDark.log &
sleep 1
echo 'Starting alert-temperatureTooLow'
/wigwag/devicejs-ng/bin/devicejs run ./alert-temperatureTooLow.js --config=/wigwag/etc/devicejs/devicejs.conf >& temperatureTooLow.log &