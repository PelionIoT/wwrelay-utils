#!/bin/bash

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

cleanup () {
	rm -rf temp_certs
}

_createRootPrivateKey() {
	openssl ecparam -out temp_certs/root_key.pem -name prime256v1 -genkey
}
_createRootCA() {
	(echo '[ req ]'; echo 'distinguished_name=dn'; echo 'prompt = no'; echo '[ ext ]'; echo 'basicConstraints = CA:TRUE'; echo 'keyUsage = digitalSignature, keyCertSign, cRLSign'; echo '[ dn ]') > temp_certs/ca_config.cnf
	(cat temp_certs/ca_config.cnf; echo 'C=US'; echo 'ST=Texas';echo 'L=Austin';echo 'O=ARM';echo 'CN=relays_arm.io_gateway_ca';) > temp_certs/root.cnf
	openssl req -key temp_certs/root_key.pem -new -sha256 -x509 -days 12775 -out temp_certs/root_cert.pem -config temp_certs/root.cnf -extensions ext
}
_createIntermediatePrivateKey() {
	openssl ecparam -out temp_certs/intermediate_key.pem -name prime256v1 -genkey
}
_createIntermediateCA() {
	(cat temp_certs/ca_config.cnf; echo 'C=US'; echo 'ST=Texas'; echo 'L=Austin';echo 'O=ARM';echo 'CN=relays_arm.io_gateway_ca_intermediate';) > temp_certs/int.cnf
	openssl req -new -sha256 -key temp_certs/intermediate_key.pem -out temp_certs/intermediate_csr.pem  -config temp_certs/int.cnf
	openssl x509 -sha256 -req -in temp_certs/intermediate_csr.pem -out temp_certs/intermediate_cert.pem -CA temp_certs/root_cert.pem -CAkey temp_certs/root_key.pem -days 7300 -extfile temp_certs/ca_config.cnf -extensions ext -CAcreateserial
}
_createDevicePrivateKey() {
	openssl ecparam -out temp_certs/device_private_key.pem -name prime256v1 -genkey
}
_createDeviceCertificate() {
	(echo '[ req ]'; echo 'distinguished_name=dn'; echo 'prompt = no'; echo '[ dn ]'; echo 'C=US'; echo 'ST=Texas';echo 'L=Austin';echo 'O=ARM';echo "OU=$OU";echo "CN=$internalid";) > temp_certs/device.cnf
	openssl req -key temp_certs/device_private_key.pem -new -sha256 -out temp_certs/device_csr.pem -config temp_certs/device.cnf
	openssl x509 -sha256 -req -in temp_certs/device_csr.pem -out temp_certs/device_cert.pem -CA temp_certs/intermediate_cert.pem -CAkey temp_certs/intermediate_key.pem -days 7300 -extensions ext -CAcreateserial
}

generate_self_signed_certs() {
	mkdir temp_certs
    _createRootPrivateKey
    _createRootCA
    _createIntermediatePrivateKey
    _createIntermediateCA
    _createDevicePrivateKey
    _createDeviceCertificate
}

generate_self_signed_certs