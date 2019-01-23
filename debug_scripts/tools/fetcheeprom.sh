#!/bin/bash
filename=$1
ip=$2
bold=$(tput bold)
fname=$(echo $filename | cut -d'.' -f 1)
#echo $fname
#echo $filename

burnEeprom() {
    cd /wigwag/wwrelay-utils/I2C
    node writeEEPROM.js $file
    if [[ $? != 0 ]]; then
        echo "Failed to write eeprom. Trying again in 5 seconds..."
        sleep 5
        burnEeprom
    fi
}

factoryReset() {
    cd /wigwag/wwrelay-utils/debug_scripts
    chmod 755 factory_wipe_gateway.sh
    ./factory_wipe_gateway.sh
}

cleanLastBurn() {
    kill $(ps aux | grep 'factory-configurator' | awk '{print $2}');
    rm -rf mcc_config*; rm -rf pal;
    rm -rf gateway_eeprom.json
}

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
        relayip=$(ifconfig | grep -A 2 -E 'wlan|eth|wlp|enp' | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
        if [[ -z $radioConfig || -z $category || -z $cloudAddress || -z $hardwareVersion ]]; then
           echo "Please enter a correct configuration file" 
        else
            if [[ $ip == '' ]];then
                echo "Please enter the IP where gateway dispatcher is running"
                read ip
                echo "Entered IP ${ip}"
            fi
            if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                cd /wigwag/wwrelay-utils/I2C
                cleanLastBurn
                echo "Starting FCC...";
                FAIL=0
                ./factory-configurator-client-armcompiled.elf &
                echo "My IP is- $relayip"
                # echo $ip':5151/relay/'$provisioning'/'$cloud'/'$category'/'$hardwareVersion'/'$radioConfig'?limit=1&'$relayip
                echo "Executing curl command"
                api='http://'$ip':5151/relay/'$provisioning'/'$cloud'/'$category'/'$hardwareVersion'/'$radioConfig'?limit=1&ip='$relayip''
                curl -s --header "secret: WZpMyRDntxFgBGBfWPleIHzoc0egcPSsBAa8jUQw5tOgbbjc3o" $api > gateway_eeprom.json &
                for job in `jobs -p`
                do
                echo $job
                    wait $job || let "FAIL+=1"
                done
                if [ "$FAIL" == "0" ]; then
                    echo "Done"
                    file="gateway_eeprom.json"
                    echo "Command ran successfully"
                    cat gateway_eeprom.json
                    line=$(head -n 1 gateway_eeprom.json)
                    if [[ $line = "No match Found in the database" ]]; then
                        rm -rf gateway_eeprom.json
                    fi
                    if [ -f "$file" ]; then
                        burnEeprom
                        factoryReset
                    else
                        rm -rf gateway_eeprom.json
                        echo "gateway_eeprom.json not found, unable to fetch a eeprom"
                        exit 1
                    fi
                else
                    echo "Failed!"
                    exit 1
                fi
            else
                echo "Please Enter a valid IP"
                exit 1
            fi
        fi
    else
        echo "File should be in json format"
        exit 1
    fi
else
    echo "${1} This file does not exist"
    exit 1
fi
