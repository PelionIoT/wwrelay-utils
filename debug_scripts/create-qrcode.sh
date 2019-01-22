#!/bin/bash

if [ "$EUID" -ne 0 ];then
    echo "Please run as root"
    exit
fi

bold=$(tput bold)
red=`tput setaf 1`
green=`tput setaf 2`
normal=$(tput sgr0)
output () {
    echo "${green}"$1"${normal}"
}

error () {
    echo "${red}"$1"${normal}"
}

cleanup () {
	rm -rf temp_certs
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

generateSHA256Fingerprint=$(openssl x509 -noout -fingerprint -sha256 -inform pem -in temp_certs/device_cert.pem | cut -d '=' -f2)

QR=$(which qrencode)
install () {
    if [ "$QR" == "" ]; then
        output "Installing qrencode..."
        sudo apt-get install qrencode
    fi
}

internalid=12345678901234567890123456789012
OU=0166f9ba7080361e2d83535a00000000

execute () {
    output "Generating device keys using CN=$internalid, OU=$OU"
    mkdir temp_certs
    createRootPrivateKey
    createRootCA
    createIntermediatePrivateKey
    createIntermediateCA
    createDevicePrivateKey
    createDeviceCertificate
    qrencode -o fingerprint-qrcode.png \{\"eid\"\:\"A-$generateSHA256Fingerprint\"\}
    display fingerprint-qrcode.png
}

install
execute