#!/bin/bash
filename=$1
ip=$2
bold=$(tput bold)
fname=$(echo $filename | cut -d'.' -f 1)
#echo $fname
#echo $filename
if [ -e $1 ]
then
    if [[ $filename == *.json ]]; then
        json2sh $filename $fname.sh
        echo "File converted to bash file "
        source <(grep -E '^\w+=' $fname.sh)
        if [[ $hardwareVersion == "r2002" ]]; then
            hardwareVersion=rp200
        else
            hardwareVersion=rp100
        fi
        echo "Debuggging Values: " $radioConfig $category $cloudAddress $hardwareVersion 
        cloud=$(echo $cloudAddress|cut -c9-125)
        provisioning=$(echo $cloudAddress | cut -d'.' -f 2)
        relayip=ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'
        if [[ -z $radioConfig || -z $category || -z $cloudAddress || -z $hardwareVersion ]]; then
           echo "Please enter a correct configuration file" 
        else
            if [[ $ip == '' ]];then
                echo "Please enter the IP where relay dispatcher is running"
                read ip
                echo "Entered IP ${ip}"
            fi
            if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                kill $(ps aux | grep 'factory-configurator' | awk '{print $2}');
                rm -rf mcc_config*; rm -rf pal;
                rm -rf eeprom.json;
                cd /wigwag/wwrelay-utils/I2C
                ./factory-configurator-client-armcompiled.elf &
                relayip=ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'
                echo $relayip
                # echo $ip':5151/relay/'$provisioning'/'$cloud'/'$category'/'$hardwareVersion'/'$radioConfig'?limit=1&'$relayip
                curl --header "secret: WZpMyRDntxFgBGBfWPleIHzoc0egcPSsBAa8jUQw5tOgbbjc3o" 'http://'$ip':5151/relay/'$provisioning'/'$cloud'/'$category'/'$hardwareVersion'/'$radioConfig'?limit=1&'$relayip > eeprom.json
                file="eeprom.json"
                echo "Command ran successfully"
                cat eeprom.json
                line=$(head -n 1 eeprom.json)
                if [[ $line = "No match Found in the database" ]]
                then
                    rm -rf eeprom.json
                fi
                if [ -f "$file" ]
                then
                    node writeEEPROM.js $file
                else
                    rm -rf eeprom.json
                    echo "eeprom.json not found, unable to fetch a eeprom"
                fi
            else
                echo "Please Enter a valid IP"
            fi 
        fi
    else
        echo "File should be in json format"   
    fi
else
    echo "${1} This file does not exist"
fi
