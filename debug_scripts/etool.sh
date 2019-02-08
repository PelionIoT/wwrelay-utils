#!/bin/bash

IP=$(ifconfig | grep -A 2 -E 'wlan|eth|wlp|enp' | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
etool_path=$1
command=$2
echo "Relay have $IP"
echo "Running etool..."

if [ $# != 2 ]; then                                                            
    echo -e "Run File as\n./etool.sh <path of the etool> <command>\n./etool.sh home/root/enterprise-tools shell"   
    exit 1                                                                      
fi  

if [ ! -f $etool_path ]; then
    echo "file not exist."
    echo -e "Run File as\n./etool.sh <path of the etool> <command>\n./etool.sh home/root/enterprise-tools shell"
    exit 1
fi

if [[ ! -d $etool_path/node_modules ]] && [[ ! -f $etool_path/package-lock.json ]]; then
    echo "Node mudules not installed so installing it..."
    cd $etool_path
   	npm install;
fi

$etool_path/bin/dcs-tools -c http://$IP:3131 -u directaccess@wigwag.com -p wigwagr0x $2

# How to run...
# ./etool.sh <path of the etool> <command>
# Example 1. ./etool.sh /home/root/enterprise-tools shell
# Example 2. ./etool.sh /home/root/enterprise-tools getSites