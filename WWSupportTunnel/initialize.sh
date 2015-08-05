#! /bin/bash

KHTun=`cat /home/root/.ssh/known_hosts | grep tunnel.wigwag.com`;
if [ "$KHTun" = "" ]
        then
        cat /wigwag/support/known_hosts >> /home/root/.ssh/known_hosts;
fi
chmod 600 /wigwag/support/relay_support_key
chown -R support:support /home/support/.ssh
node /wigwag/support/index.js
