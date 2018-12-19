#!/bin/bash
# This has to be on ext4 fs USB stick. NTFS is not detected by our gateway
# /etc/init.d/deviceOS-watchdog humanhalt
# /etc/init.d/deviceOS-watchdog humanhalt

# killall node
if [ ! -f ./led.sh ]; then
    ledcontrol=/wigwag/system/bin/led
else
    ledcontrol=./led.sh
fi
source "/wigwag/system/lib/bash/relaystatics.sh"
function grabip() {
    ifconfig > ifconfig.txt
}
function grabip2() {
    ifconfig > ifconfig2.txt
}
function dhcpthis(){
    udhcpc -n
}
$ledcontrol 255 255 255
IP=$(ifconfig | grep -A 2 -E 'wlan|eth|wlp|enp' | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
echo "Found IP=$IP"
if [[ $IP == '' ]]; then
    echo "Acquiring new IP..."
    ifconfig eth0 down
    hexchars="0123456789ABCDEF"
    end=$( for i in {1..6} ; do echo -n ${hexchars:$(( $RANDOM % 16 )):1} ; done | sed -e 's/\(..\)/:\1/g' )
    ifconfig eth0 hw ether 00:a5:09$end
    ifconfig eth0 up
    udhcpc eth0
fi

# /etc/init.d/devjssupport start

#--------Commands go here
useradd -p $(openssl passwd -1 maestro) maestro

grabip
# dhcpthis
grabip2
# sleep 15
# curl http://localhost:3000/start
IP=$(ifconfig | grep -A 2 -E 'wlan|eth|wlp|enp' | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
curl -X POST -H 'Content-type: application/json' --data '{"text":"USB Reports- IP='$IP', RELAYID='$relayID'"}' https://hooks.slack.com/services/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
# /etc/init.d/relayterm start
# rm -rf /userdata/etc/devicejs/db/
# sleep 5
$ledcontrol 255 255 255
