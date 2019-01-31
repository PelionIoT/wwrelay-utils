## Purpose
- To fetch the gateway eeproms from the gateway dispatcher and burn it on the edge gateway

## Requirements
- Make sure the machine where gateway dispatcher is running and edge gateway should be in same network
- Make sure you edit the check.json file according to the requirements

## Setup
- Start the edge-gw-provisioning-tool on a machine. Refer to this link [https://github.com/WigWagCo/edge-gw-provisioning-tool]
- Get into the edge gateway
- Go to the path
    `cd /wigwag/wwrelay-utils/debug_scripts/tools`
- Run (This installs all the dependencies which are needed by the tool)
    `npm install`

## Execution
     node fetch.js check.json
- Execute the above command, the program looks for the gateway dispatcher’s IP  in the local network
- As soon as it obtains the IP of the gateway dispatcher, the program fetches the eeprom according to the specifications provided in check.json. 
- Once, the fetched eeprom is written to gateway_eeprom.json, erasing of existing eeprom on gateway begins
- Wait till the writing and verification of the new eeprom process finishes

## Sample check.json

`{
    "hardwareVersion": "r2002",
    "radioConfig": "10",
    "ledConfig": "01",
    "category": "development",
    "cloudAddress": "https://gateways.mbedcloudintegration.net",
    "gatewayServicesAddress": "https://gateways.mbedcloudintegration.net"
}`
