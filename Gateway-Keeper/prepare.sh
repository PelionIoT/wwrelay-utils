#!/bin/bash
username=$(whoami)
IP=$(ifconfig | grep -A 2 -E 'wlan|eth|wlp3s0|enp0s25' | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
ARP=$(which arp-scan)
EXPECT=$(which expect)
ARP=$(which arp-scan)
if [[ $ARP == "" ]];then
    echo "arp-scan is not installed in your system so installing it..."
    sudo apt-get install arp-scan
    # testmystring does not contain c0
fi
EXPECT=$(which expect)
if [[ $EXPECT == "" ]];then
    echo "arp-scan is not installed in your system so installing it..."
    sudo apt-get install expect
    # testmystring does not contain c0
fi
echo "Your IP is -- $IP"
sudo ./utils/start.sh $IP $username 