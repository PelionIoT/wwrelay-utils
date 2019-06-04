#!/bin/bash

# Copyright (c) 2018, Arm Limited and affiliates.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

bold=$(tput bold)
red=`tput setaf 1`
green=`tput setaf 2`
normal=$(tput sgr0)
output () {
    echo "${green}"$1"${normal}"
}

error () {
    echo "${red}"$1"${normal}"
	exit 1
}

SCRIPT_DIR="/wigwag/wwrelay-utils/debug_scripts"
I2C_DIR="/wigwag/wwrelay-utils/I2C"

cleanup () {
	cd $SCRIPT_DIR
	rm edgestatus.json
	rm edgestatus.sh
	rm old_eeprom.json
	rm old_eeprom.sh
	rm -rf temp_certs
}

getEdgeStatus() {
	cd $SCRIPT_DIR
	edgestatusreq=$(curl localhost:9101/status)
	stat=$(echo "$edgestatusreq")
	echo $stat > edgestatus.json
}

convertStatusToBash() {
	cd $SCRIPT_DIR
	PATH=/wigwag/system/lib/bash:$PATH /wigwag/system/bin/json2sh edgestatus.json edgestatus.sh
	source ./edgestatus.sh
}


createRootPrivateKey() {
	openssl ecparam -out temp_certs/root_key.pem -name prime256v1 -genkey
}
createRootCA() {
	(echo '[ req ]'; echo 'distinguished_name=dn'; echo 'prompt = no'; echo '[ ext ]'; echo 'basicConstraints = CA:TRUE'; echo 'keyUsage = digitalSignature, keyCertSign, cRLSign'; echo '[ dn ]') > temp_certs/ca_config.cnf
	(cat temp_certs/ca_config.cnf; echo 'C=US'; echo 'ST=Texas';echo 'L=Austin';echo 'O=WigWag Inc';echo 'CN=relays_wigwag.io_relay_ca';) > temp_certs/root.cnf
	openssl req -key temp_certs/root_key.pem -new -sha256 -x509 -days 12775 -out temp_certs/root_cert.pem -config temp_certs/root.cnf -extensions ext
}

createIntermediatePrivateKey() {
	openssl ecparam -out temp_certs/intermediate_key.pem -name prime256v1 -genkey
}
createIntermediateCA() {
	(cat temp_certs/ca_config.cnf; echo 'C=US'; echo 'ST=Texas'; echo 'L=Austin';echo 'O=WigWag Inc';echo 'CN=relays_wigwag.io_relay_ca_intermediate';) > temp_certs/int.cnf
	openssl req -new -sha256 -key temp_certs/intermediate_key.pem -out temp_certs/intermediate_csr.pem  -config temp_certs/int.cnf
	openssl x509 -sha256 -req -in temp_certs/intermediate_csr.pem -out temp_certs/intermediate_cert.pem -CA temp_certs/root_cert.pem -CAkey temp_certs/root_key.pem -days 7300 -extfile temp_certs/ca_config.cnf -extensions ext -CAcreateserial
}


createDevicePrivateKey() {
	openssl ecparam -out temp_certs/device_private_key.pem -name prime256v1 -genkey
}

createDeviceCertificate() {
	(echo '[ req ]'; echo 'distinguished_name=dn'; echo 'prompt = no'; echo '[ dn ]'; echo 'C=US'; echo 'ST=Texas';echo 'L=Austin';echo 'O=WigWag Inc';echo "OU=$OU";echo "CN=$internalid";) > temp_certs/device.cnf
	openssl req -key temp_certs/device_private_key.pem -new -sha256 -out temp_certs/device_csr.pem -config temp_certs/device.cnf
	openssl x509 -sha256 -req -in temp_certs/device_csr.pem -out temp_certs/device_cert.pem -CA temp_certs/intermediate_cert.pem -CAkey temp_certs/intermediate_key.pem -days 7300 -extensions ext -CAcreateserial
}

readEeprom() {
	cd $SCRIPT_DIR
	output "Reading existing eeprom..."
	# cat /sys/bus/i2c/devices/1-0050/eeprom > old_eeprom.json
	cp /userdata/edge_gw_config/identity.json old_eeprom.json
	#convert json to sh
	PATH=/wigwag/system/lib/bash:$PATH  /wigwag/system/bin/json2sh old_eeprom.json old_eeprom.sh
	source ./old_eeprom.sh
}

findGatewayServiceAddressFromMDS() {
	if [[ $lwm2mserveruri = *"mds-integration-lab"* ]]; then
		gatewayAddress="https://gateways.mbedcloudintegration.net"
	elif [[ $lwm2mserveruri = *"mds-systemtest"* ]]; then
		gatewayAddress="https://gateways.mbedcloudstaging.net"
	elif [[ $lwm2mserveruri = *"lwm2m.us-east-1"* ]]; then
		gatewayAddress="https://gateways.us-east-1.mbedcloud.com"
	elif [[ $lwm2mserveruri = *"lwm2m.ap-northeast-1"* ]]; then
		gatewayAddress="https://gateways.ap-northeast-1.mbedcloud.com"
	else
		gatewayAddress="https://unknown.mbedcloud.com"
	fi
}

burnEeprom() {
    cd $I2C_DIR
    node writeEEPROM.js $eeprom_file
    if [[ $? != 0 ]]; then
        output "Failed to write eeprom. Trying again in 5 seconds..."
        sleep 5
        burnEeprom
    fi
}

factoryReset() {
	cd $SCRIPT_DIR
    chmod 755 factory_wipe_gateway.sh
    ./factory_wipe_gateway.sh
}

resetDatabase() {
	cd $SCRIPT_DIR
	output "Deleting gateway database"
	rm -rf /userdata/etc/devicejs/db
}

restart_services() {
	cd $SCRIPT_DIR
	chmod 755 reboot_edge_gw.sh
	source ./reboot_edge_gw.sh
}

execute () {
	OU=$(echo $lwm2mserveruri | cut -d'=' -f 2 | cut -d'&' -f 1)
	if [[ $status == "connected" ]]; then
		output "Edge-core is connected..."
		# Check if identity file is present. If not then assume we are not in factory mode (either BYOC or developer)
		# auto create gateway identity

		if [ ! -f /userdata/edge_gw_config/identity.json ]; then
			output "Creating developer self-signed certificate!"
			findGatewayServiceAddressFromMDS
			cd /wigwag/wwrelay-utils/debug_scripts/get_new_gw_identity/developer_gateway_identity
			./bin/create-dev-identity -g $gatewayAddress -p DEV0
			mkdir /userdata/edge_gw_config
			cp identity.json /userdata/edge_gw_config/identity.json
			cp identity.json /userdata/edge_gw_config/identity_original.json
		fi
		if [ -f /userdata/edge_gw_config/identity.json ]; then
			output "/userdata/edge_gw_config/identity.json exists! Checking if deviceID is same..."
			if [ ! -f /userdata/edge_gw_config/identity.sh ]; then
				PATH=/wigwag/system/lib/bash:$PATH /wigwag/system/bin/json2sh /userdata/edge_gw_config/identity.json /userdata/edge_gw_config/identity.sh
			fi
			source /userdata/edge_gw_config/identity.sh
			if [[ $internalid == $deviceID ]]; then
				output "EEPROM already has the same deviceID. No need for new eeprom. Bye!"
				exit 0
			fi
		fi

		# Read existing eeprom
		readEeprom

		if [[ $internalid != $deviceID ]]; then
			output "Generating device keys using CN=$internalid, OU=$OU"
			cd $SCRIPT_DIR
			mkdir temp_certs
			createRootPrivateKey
			createRootCA
			createIntermediatePrivateKey
			createIntermediateCA
			createDevicePrivateKey
			createDeviceCertificate
			if [[ $? -eq 0 ]]; then
				# Stop edge-core before taking a snapshot of mcc_config
				#output "Stopping edge core..."
				#kill $(ps aux | grep -E 'edge-core|edge_core' | awk '{print $2}');

				resetDatabase
				output "Creating new eeprom with new self signed certificate..."
				cd $SCRIPT_DIR
				node generate-new-eeprom.js $internalid
				if [[ $? -eq 0 ]]; then
					cleanup
					output "Success! You can now write the new eeprom."
					eeprom_file="$SCRIPT_DIR/new_eeprom.json"
					burnEeprom
					rm -rf $SCRIPT_DIR/new_eeprom.json
					/etc/init.d/deviceOS-watchdog start
					sleep 5
					restart_services
				else
					error "Failed to create new eeprom!"
				fi
			else
				error "Failed to read existing eeprom!"
			fi
		else
			output "EEPROM already has the same deviceID. No need for new eeprom. Bye!"
			exit 0
		fi
	else
		error "Edge-core is not connected yet. Its status is- $status. Exited with code $?. Please try again later!"
	fi
}

getEdgeStatus
convertStatusToBash
execute