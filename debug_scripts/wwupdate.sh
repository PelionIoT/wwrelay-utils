#!/bin/bash
/etc/init.d/deviceOS-watchdog humanhalt
/etc/init.d/deviceOS-watchdog humanhalt

killall node
ledcontrol=/wigwag/system/bin/led
function grabip() {
    ifconfig > ifconfig.txt
}
function grabip2() {
    ifconfig > ifconfig2.txt
}
function dhcpthis(){
    udhcpc -n
}
$ledcontrol 5 5 5
udhcpc eth0
/etc/init.d/devjssupport start


#--------Commands go here

grabip
dhcpthis
grabip2
sleep 15
curl http://localhost:3000/start
/etc/init.d/relayterm start
rm -rf /userdata/etc/devicejs/db/
sleep 5
$ledcontrol 0 10 0
