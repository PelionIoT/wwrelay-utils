#!/bin/bash
relayID={{apikey}}
versionsFile={{relayFirmwareVersionFile}}
factoryVersionsFile={{factoryFirmwareVersionFile}}
userVersionsFile={{userFirmwareVersionFile}}
upgradeVersionsFile={{upgradeFirmwareVersionFile}}
pairingCode={{pairingCode}}
serialNumber={{apikey}}
hardwareVersion={{hardwareVersion}}
radioConfig={{radioConfig}}
ledConfig={{ledConfig}}
cloudServer={{cloudurl}}
devicejsServer={{clouddevicejsurl}}
devicedbServer={{cloudddburl}}
partitionScheme={{partitionScheme}}
cloud={{ARCH_CLOUD_URL}}
cloudAddress={{ARCH_CLOUD_DEVJS_URL}}
databaseConfig={{LOCAL_DEVICEDB_PORT}}
serverkey_path={{SSL_CERTS_PATH}}/server.key.pem
servercert_path={{SSL_CERTS_PATH}}/server.cert.pem
serverca_path={{SSL_CERTS_PATH}}/ca.cert.pem
serverintermediate_path={{SSL_CERTS_PATH}}/intermediate.cert.pem
clientkey_path={{SSL_CERTS_PATH}}/client.key.pem
clientcert_path={{SSL_CERTS_PATH}}/client.cert.pem
clientca_path={{SSL_CERTS_PATH}}/ca.cert.pem
clientintermediate_path={{SSL_CERTS_PATH}}/intermediate.cert.pem
ethernetMac_path={{ethernetmac}}

if [[ $hardwareVersion = "0.1.1" ]]; then
	PIN_m1_reset=98
	PIN_m1_data=97
	PIN_m1_clock=96
	PIN_m2_reset=101
	PIN_m4_reset=102
	PIN_m4_data=104
	PIN_m4_clock=103
elif [[ $hardwareVersion = "r2002" ]]; then
	PIN_wdog_reset=99
	PIN_p1_reset=37
	PIN_p2_reset=39
	PIN_m1_reset=104
	PIN_m1_data=103
	PIN_m1_clock=102
	PIN_m2_reset=119
	PIN_m2_data=118
	PIN_m2_clock=105
fi

