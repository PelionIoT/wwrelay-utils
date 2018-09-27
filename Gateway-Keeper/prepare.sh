#!/bin/bash
username=$(whoami)
IP=$(ifconfig | grep -A 2 -E 'wlan|eth|wlp3s0|enp0s25' | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
# ARP=$(which arp-scan)
# EXPECT=$(which expect)
# echo "arp-scan is -- $ARP"
# echo "expect is -- $EXPECT"
echo "Your IP is -- $IP"
sudo ./utils/start.sh $IP $username 