#! /bin/bash

if [ ! -e /updater/relay-updater/downloads ]; then
   mkdir -p /updater/relay-updater/downloads
fi

if [ ! -e /updater/relay-updater/installs ]; then
   mkdir -p /updater/relay-updater/downloads
fi

KHTun=`cat /home/root/.ssh/known_hosts | grep tunnel.wigwag.com`;
if [ "$KHTun" = "" ]
        then
        cat /wigwag/support/known_hosts >> /home/root/.ssh/known_hosts;
fi

/wigwag/support/checkForUpdates.sh &
chmod 600 /wigwag/support/relay_support_key
chown -R support:support /home/support/.ssh
node /wigwag/support/index.js
