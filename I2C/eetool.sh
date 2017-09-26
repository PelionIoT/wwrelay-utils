#!/bin/bash
#===========================================================================================================================
#============================================================================================================+==============
# Configuration
#===========================================================================================================================
#===============================================================================================================+===========

fieldtype="ascii"
fields=(relayID hardwareVersion firmwareVersion radioConfig year month batch ethernetMAC sixBMAC relaySecret pairingCode ledConfig cloudURL devicejsCloudURL devicedbCloudURL ssl_client_certificate ssl_client_key ssl_server_certificate ssl_server_key ssl_ca_ca ssl_ca_intermediate)
declare -A fields_start;
declare -A fields_end;
declare -A fields_page;
declare -A fields_description;
declare -A fields_storetype
declare -A iccpages;
declare -A clouds_ssl_ca_ca;
declare -A clouds_ssl_ca_intermediate;
declare -A clouds_cloudURL;
declare -A clouds_devicejsCloudURL;
declare -A clouds_devicedbCloudURL;

fields_description["relayID"]="The serial number of the WigWag Relay"
fields_page["relayID"]=0x50
fields_start["relayID"]=0
fields_end["relayID"]=9
fields_storetype["relayID"]="ascii"

fields_description["hardwareVersion"]="The version of the hardware that this RelayID is paired with"
fields_page["hardwareVersion"]=0x50
fields_start["hardwareVersion"]=10
fields_end["hardwareVersion"]=14
fields_storetype["hardwareVersion"]="ascii"

fields_description["firmwareVersion"]="The version of the firmware that this RelayID is paired with"
fields_page["firmwareVersion"]=0x50
fields_start["firmwareVersion"]=15
fields_end["firmwareVersion"]=19
fields_storetype["firmwareVersion"]="ascii"

fields_description["radioConfig"]="The radios included in this hardware Version"
fields_page["radioConfig"]=0x50
fields_start["radioConfig"]=20
fields_end["radioConfig"]=21
fields_storetype["radioConfig"]="ascii"

fields_description["year"]="The year this hardware version was manufactured"
fields_page["year"]=0x50
fields_start["year"]=22
fields_end["year"]=22
fields_storetype["year"]="ascii"

fields_description["month"]="The month this hardware version was manufactured"
fields_page["month"]=0x50
fields_start["month"]=23
fields_end["month"]=23
fields_storetype["month"]="ascii"

fields_description["batch"]="The batch this hardware version was manufactured"
fields_page["batch"]=0x50
fields_start["batch"]=24
fields_end["batch"]=24
fields_storetype["batch"]="ascii"

fields_description["ethernetMAC"]="The ethernet MAC for the hardware platfrom"
fields_page["ethernetMAC"]=0x50
fields_start["ethernetMAC"]=25
fields_end["ethernetMAC"]=30
fields_storetype["ethernetMAC"]="dec-comma"

fields_description["sixBMAC"]="The sixbRadio MAC for the hardware platfrom"
fields_page["sixBMAC"]=0x50
fields_start["sixBMAC"]=31
fields_end["sixBMAC"]=38
fields_storetype["sixBMAC"]="dec-comma"

fields_description["relaySecret"]="The relaySecret associated with the PairingCode"
fields_page["relaySecret"]=0x50
fields_start["relaySecret"]=39
fields_end["relaySecret"]=70
fields_storetype["relaySecret"]="ascii"

fields_description["pairingCode"]="The pairingCode assocated with the RelayID"
fields_page["pairingCode"]=0x50
fields_start["pairingCode"]=71
fields_end["pairingCode"]=95
fields_storetype["pairingCode"]="ascii"

fields_description["ledConfig"]="Hardware configuration flag for relays supporting RGB 01 and RBG 02 leds"
fields_page["ledConfig"]=0x50
fields_start["ledConfig"]=96
fields_end["ledConfig"]=97
fields_storetype["ledConfig"]="ascii"

fields_description["cloudURL"]="The url for the cloud this relay is associated with"
fields_page["cloudURL"]=0x51
fields_start["cloudURL"]=0
fields_end["cloudURL"]=255
fields_storetype["cloudURL"]="ascii"

fields_description["devicejsCloudURL"]="The url for the devicejs server cloud this relay is associated with"
fields_page["devicejsCloudURL"]=0x52
fields_start["devicejsCloudURL"]=0
fields_end["devicejsCloudURL"]=255
fields_storetype["devicejsCloudURL"]="ascii"

fields_description["devicedbCloudURL"]="The url for the devicedbCloudURL server cloud this relay is associated with"
fields_page["devicedbCloudURL"]=0x53
fields_start["devicedbCloudURL"]=0
fields_end["devicedbCloudURL"]=255
fields_storetype["devicedbCloudURL"]="ascii"

fields_description["ssl_client_key"]="SSL Certificate needed for authentication against the cloud"
fields_page["ssl_client_key"]="client.key.pem"
fields_start["ssl_client_key"]="{\"ssl\":{\"client\":{\"key\":"
fields_end["ssl_client_key"]="}}}"
fields_storetype["ssl_client_key"]="file"

fields_description["ssl_client_certificate"]="SSL Certificate needed for authentication against the cloud"
fields_page["ssl_client_certificate"]="client.cert.pem"
fields_start["ssl_client_certificate"]="{\"ssl\":{\"client\":{\"certificate\":"
fields_end["ssl_client_certificate"]="}}}"
fields_storetype["ssl_client_certificate"]="file"

fields_description["ssl_server_key"]="SSL Certificate needed for authentication against the cloud"
fields_page["ssl_server_key"]="server.key.pem"
fields_start["ssl_server_key"]="{\"ssl\":{\"server\":{\"key\":"
fields_end["ssl_server_key"]="}}}"
fields_storetype["ssl_server_key"]="file"

fields_description["ssl_server_certificate"]="SSL Certificate needed for authentication against the cloud"
fields_page["ssl_server_certificate"]="server.cert.pem"
fields_start["ssl_server_certificate"]="{\"ssl\":{\"server\":{\"certificate\":"
fields_end["ssl_server_certificate"]="}}}"
fields_storetype["ssl_server_certificate"]="file"

fields_description["ssl_ca_ca"]="SSL Certificate needed for authentication against the cloud"
fields_page["ssl_ca_ca"]="ca.cert.pem"
fields_start["ssl_ca_ca"]="{\"ssl\":{\"ca\":{\"certificate\":"
fields_end["ssl_ca_ca"]="}}}"
fields_storetype["ssl_ca_ca"]="file"

fields_description["ssl_ca_intermediate"]="SSL Certificate needed for authentication against the cloud"
fields_page["ssl_ca_intermediate"]="intermediate.cert.pem"
fields_start["ssl_ca_intermediate"]="{\"ssl\":{\"intermediate\":{\"certificate\":"
fields_end["ssl_ca_intermediate"]="}}}"
fields_storetype["ssl_ca_intermediate"]="file"

clouds_ssl_ca_ca["production"]="-----BEGIN CERTIFICATE-----\nMIIFnjCCA4agAwIBAgIJALK9uBsr+g83MA0GCSqGSIb3DQEBCwUAMFwxCzAJBgNV\nBAYTAlVTMQ4wDAYDVQQIDAVUZXhhczEPMA0GA1UEBwwGQXVzdGluMRMwEQYDVQQK\nDApXaWdXYWcgSW5jMRcwFQYDVQQDDA5XaWdXYWcgUm9vdCBDQTAeFw0xNjA2MDEy\nMDM5MjFaFw0zNjA1MjcyMDM5MjFaMFwxCzAJBgNVBAYTAlVTMQ4wDAYDVQQIDAVU\nZXhhczEPMA0GA1UEBwwGQXVzdGluMRMwEQYDVQQKDApXaWdXYWcgSW5jMRcwFQYD\nVQQDDA5XaWdXYWcgUm9vdCBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC\nggIBALc+N4Mh1t8bDezX27BMAttTI/jfUiDfjeNb5w9F1T3bVg8rp1Ov8BIltAVU\nyqJnM+fvI/rwYwFRPMZY7zW8X1oSvgtKarsPqCZR2QJiv0cTSi/3gPOSunwIT4W7\nBnLAJhy3RoYhhxApmGyiUOcOMzgB3rlEQLk7DbaBf6SN99ONuarRjuzVOvyaFOtN\n549DM7HoS0EM7H6iXbJ5O6jHKi62ikW8KmUQhwjn165A0GPM1L90xmdGYSvsb4z3\nj/A0eewaEFlwBqpbgqd+JFqRiSTekh7a99/V8CJN8LM8wUZRbUZeMxaoTikBHSS2\nXpzBE7IeOU+nuGzPaqEt/7FyuVTRqcIljCLg2JwWDunXSMQS9BjnrCeyXfXYjHzq\n+A56Zbxh02dv6af+sPOQU+MqInTzigdVAo48tUmMWEIRjy40LDUPpzCTY9u/OGKM\nwDwCi41EaVMzxt4O2jkMRdZtimxrGzSHhJ8lLYvjNL5VN5IkLMSqxP8nZQhempfC\nW6DIaXLpp47WrrM7yYy4xQKRvcOQgjYjyoHKsZhvAVMHQlgJbmFy5pkQ5fFMeF69\n8IY+fO1L+4NKyXjxwrx4qsYVlpdsdq1Gq3GZLFRZK5+eWz1B+jfvByd7rJgPquln\ns0i0dQTmdArgM7pfbY0q5XQQ9FZQKXXeFT87RmIrQYJVS95DAgMBAAGjYzBhMB0G\nA1UdDgQWBBT7LAJkl2A4kJDKW0cHcaOJGs1g4jAfBgNVHSMEGDAWgBT7LAJkl2A4\nkJDKW0cHcaOJGs1g4jAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAN\nBgkqhkiG9w0BAQsFAAOCAgEAKEkegYys0knM0hSM6FnqJ+VYSb6cZL22j8r+V7al\nDd+OxNHrWPFw8AShDvbHKCi9icG0oe6vMvKgVb8/4y2Gcl5pPsk7zUdYZAkYEEN9\ncHIYvi49U1An77gA0OH3CUjyrjnMUuvozrTstQYHZfcl6to3ZfZerkwXYXm6xpgJ\nmOqEhJ5v0DgcFjCoYMGbr5/G2Kw3t69jYRxK3BfV5ZNqU2ct2ZJeDhD1c6mGPncu\ntKZp222XZZ3UIOVGodc3o8Zo6DJTMgh6A2CKSh3bfD8VIS+IzAJG4XmW+Vw7ffRm\nsmRdRd9TFhBMerGN08TJw7QOO7j5aeT+eeTPExQTnJg5I3vosejxP/kx54CHDvmU\n78N3R8jV6FTf0q+C2/rjsWY4uPvs4HiI/KIQmaNUubrgZmyRubr5Zl2WLbzkUoui\nytL1xdkSCQg8+UW0uD+oKuZ/QJwWmrL+9McwZnWI2DpysHeQa2Uswo9nomtF4gfS\nnE/sZOvLdgJyzCYxvegsrzsenr3KjrA+lhrmiB/A1HlfBlYpWbJDkE+7Atcx62Xx\nz03bTpWcz6Geq4mmYK/JXMGPr39gkVi/Tp14uVcS9fRn30+zWO5y6xW09fHDsNCT\n4lO7Pxfh/qY/lMcb8aQaVbbwqfD+VpC/8UDrbo0niBatG33uIxEiSabpJe8elgGJ\nciE=\n-----END CERTIFICATE-----"
clouds_ssl_ca_intermediate["production"]="-----BEGIN CERTIFICATE-----\nMIIFkTCCA3mgAwIBAgICEAAwDQYJKoZIhvcNAQELBQAwXDELMAkGA1UEBhMCVVMx\nDjAMBgNVBAgMBVRleGFzMQ8wDQYDVQQHDAZBdXN0aW4xEzARBgNVBAoMCldpZ1dh\nZyBJbmMxFzAVBgNVBAMMDldpZ1dhZyBSb290IENBMB4XDTE2MDYwMTIwNDUyMVoX\nDTI2MDUzMDIwNDUyMVowUzELMAkGA1UEBhMCVVMxDjAMBgNVBAgMBVRleGFzMRMw\nEQYDVQQKDApXaWdXYWcgSW5jMR8wHQYDVQQDDBZXaWdXYWcgSW50ZXJtZWRpYXRl\nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEArY6aTP1Pv2+KcXOj\nnb1Sln6ty+MJH/JKfzsh8UMQ0CXX9pEvVKdDBkA8zAHULxPvmwpNZI1VIZTH6ELK\n/C5EBFWQiiX37KvQ/C+hAZdOau/aLSVD4f9sdGKVUcFigNmLIyff4ltJ60qp6Zzi\ndG2aWGcNncmp8J8mryscZyAOAWtVm/niWoU5Q1siJYMDEnYaO/y3ypPlOxpzX15k\nlFnkwkTQAc97eKqF1xBFa7NEZQm7okO+RR9eFfT2ibb/kQHmI56cD74XDN/knkmk\nFS6F6m0jZ9CmrJw/K0nE2a4rAKhKY44Brnm+k57iD+6EMIL7i42n28z0R5lueDhu\nuAHdngNTreSePl+gX+CCX0IxgCnG0xj0FwDxZdpcSuqHDY/qFocsFDeuxUbYOtB1\n1n2HxJ4E7uFvrJ+UHW1bAZtecQd23Owetb3OevAAn+1NnNjF1wF6t05kxNjv0DSn\n0qP82T80jAI/TzIuZMdE88ykHYSoDEfj0f0WwowihT6rKQQWvH3bk7gds6GVOzh9\nLHxk+3Q+mkzixe6UN/VhpXq4nz1WewR1VfvY6rchi2q5vqFHhG/DcuRwNGfvbcjs\nbFz5K/PyicH4i2bXPJIjoulNv4aLOWQXil+3tzn8Uqv21SGqpswI6h6BTffMTeHu\n/0R8ffDW4k6r++j8SuqP4GaaqrsCAwEAAaNmMGQwHQYDVR0OBBYEFA/Xg70Ofws0\nCHd0s49+UHtTL613MB8GA1UdIwQYMBaAFPssAmSXYDiQkMpbRwdxo4kazWDiMBIG\nA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMA0GCSqGSIb3DQEBCwUA\nA4ICAQAMNF3iH3cEn2rMeb3C2pvvG4E4arbE9jW/lbo8a5+aWTlsJlKmDvHrpjkJ\nEEmizB716Ev0U51l+4aTvgXyBYRF3GhrgF64XJWinJQ7jc8DS5yGyGAruX87wgoq\nhL/xsmOVuOxt2ZkH9ev6xwkCHCO7Zp2jMpJAUq/p+4Uv9wxKB9/jDYhdypjgPxSP\nmPNqwlF1NQvILtOfQ0PEyVw+4Hki7alC3AD8IPbVN71rHdroASRyYqZWKfQicKIj\nwv1K6d+X9IvFy2sinHn+H0iCa1CD69oR96fCAz+seNcM1rvx8ctND9LD7wbq2DKN\nTrK0ROSrxXWdVFVn/YpkpCnQKnwPnnOqJ7Yaicw1toVfYnXfZe0ZExHLUoYlFVH6\nrIgTSsnYpLeAtuc/P4orF5LGmzNjob3rIv3vNJIyBEXnydz2aEEySIYZH1k7kaZa\n0TpeA6+Fgs0yqgI7Gdf/gV5jDq2wO7FVBR1eqZMkVI8FzKrffCYQeKWADbi/UQOJ\n+mm0WykSLkFXi+yE36ijjq9X2HxLceO9XQYTiNtenQ9+bZk526L35rVhxszPFCbX\nwPS0BDH1hHcabQMXTAHZYX2w8ddlCWd9KLHIkSntsjxkiDsQzcd6hdd0mvWSp34H\n9muRVbct5CXpPowSYuuzk8CJtxlckKIqnm59ScGgcPk1IhMQlw==\n-----END CERTIFICATE-----"
clouds_cloudURL["production"]="https://cloud1.wigwag.com"
clouds_devicejsCloudURL["production"]="https://devicejs1.wigwag.com"
clouds_devicedbCloudURL["production"]="https://devicedb1.wigwag.com"

clouds_ssl_ca_ca["fsg"]="-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAu/LL+EZIArqzUUMpXFfuLVXP4fgr78gOhhbambjboxinkwNq\nwfsIqI7mX3IEOzR/y9YeAGOAR0NGbSH3ps7qM71LwIZNUowGJqYGCnvVLkr0KkSP\naMJg6nanz/64ks+91MiBOlVAp083rU/ri54oRVMWMoiL3WhNCj5dvTrWDB1CUxd6\n/xHLEzv/v29d5iUhQY1V5JFobAcfmI370NhBbeE2uihNszkot6eTzNeq/8sig+Wz\nVQx8UkGVekNLc/afFKpZ+AQRorL02m1ZXruO+Sb2/MvkCZWvxqspg7FQmC4yO+AN\nqjCumeojvWVyaFx5Go6+UCtTrJfyWDRyiIqBTwIDAQABAoIBAD0zwiHV2QsyesQC\nh8xvQbr3j5s48i3ByqD1fjfCj5sboy3nVfNW6Kni5re77A7PeLIKxng/7nzGNn/B\nKODjzjYM9Ub7NOClgjdBpwPw8SmC9OFys/RcH60Z+Gltu/LqvRk2NYamTkhtLmc8\neCpd1SVF+ht4hXsSxMuKJYJCT4Nf0FvFwwmck4sqiECrDFnRxvoX5UkI7U+fu7d2\nFB9NKtLN98awrHZ+WrktWFJluP1GG093OffL+AvHijIaD33jDSSnC/rlg1N6vKlr\n7RhMmTNwHP2jKxSyZ883lXARpBB7gLrogjDUS+K8A1jtL2G8we061LiYYv61cuhp\nxSkC+5kCgYEA71CUb5koKgI+baD1hEhNEyMUCK89apsyaRSK6CL0nAujzkIHgso5\nDyKOTUes9OG2uuJ9LMzXgDLLo4ALyvFkrPWWnOrekCU/mpwAUId/4AP8bwnyqYtE\npoME+pA1BVB5tPmfpAxoHVubRmJr+KSsgdeLVj7hwLY4RGC4VaQkmEsCgYEAyQ1n\nDIJb6QUElU64Ekw8WoJW58kcyH0BJyQPmvlc1kQ6qoWIrGcyfcCFteQpANzYk0ak\neYpa3n8ei4CmQEYU0YI4HSMzXsM6kC/Cl/Vn7fVm+/MuuaMpVhz4Z+9PYW9FonPW\nw+2GY/u4oTKdWFVWXLKNWHS+C43NUBDueQ7D4I0CgYANYSPrWVS1hIqY9nbDfodQ\nmpV0Jtf4LdUTquJZOBsU3lG6JlblKQknn3b1OxygVD4zFJaK+qjRsgVQjsgaAITw\nZoqVG0x2Ip77td0Oo4SysYZbbuLyN6cO6CRPHeDY+zbSt2IFeewYOBbmSHpg3FQI\nrlRL7hgQ/h8HM6EaqKKjIQKBgQCXtEg8dSS6+DFUJBjanbGwrca7kNHqKgCzsw8f\nZed6OfN2ddoCFMBRiPKbo/SYlQvKXTSADTixyIOYydMojnjo+XQz8Dqz12YaJB+W\nH/Ny54f0trNcGdR4CNYbPsTMBXUqtnOoVVLhoK/Y2mNFoubOfWAQDc7U0wPH1W7L\n46tDhQKBgHOj3Iyqg7n+dGEzq0ygMThDoZ/jgnARNQ/WSrzSAgVlo6FjWVlleC4f\nBWAoxf28Axag7eYnAsU6SPV0NEMrCc+D55L9kbPPQkge+vzkSpLkA+8LboOGofx8\nIA3tuYCTqG6gPxMEarYKyaDFKynC2x1x4E5VcmF2a7nGt3R6DYno\n-----END RSA PRIVATE KEY-----"
clouds_ssl_ca_intermediate["fsg"]="-----BEGIN CERTIFICATE-----\nMIIFTDCCAzSgAwIBAgICJY0wDQYJKoZIhvcNAQELBQAwUzELMAkGA1UEBhMCVVMx\nDjAMBgNVBAgMBVRleGFzMRMwEQYDVQQKDApXaWdXYWcgSW5jMR8wHQYDVQQDDBZX\naWdXYWcgSW50ZXJtZWRpYXRlIENBMB4XDTE2MDgwNDEzMjAwOVoXDTM2MDczMDEz\nMjAwOVowWDELMAkGA1UEBhMCVVMxDjAMBgNVBAgMBVRleGFzMQ8wDQYDVQQHDAZB\ndXN0aW4xEzARBgNVBAoMCldpZ1dhZyBJbmMxEzARBgNVBAMMCldXUkwwMDAwVDcw\nggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC78sv4RkgCurNRQylcV+4t\nVc/h+CvvyA6GFtqZuNujGKeTA2rB+wiojuZfcgQ7NH/L1h4AY4BHQ0ZtIfemzuoz\nvUvAhk1SjAYmpgYKe9UuSvQqRI9owmDqdqfP/riSz73UyIE6VUCnTzetT+uLnihF\nUxYyiIvdaE0KPl29OtYMHUJTF3r/EcsTO/+/b13mJSFBjVXkkWhsBx+YjfvQ2EFt\n4Ta6KE2zOSi3p5PM16r/yyKD5bNVDHxSQZV6Q0tz9p8Uqln4BBGisvTabVleu475\nJvb8y+QJla/GqymDsVCYLjI74A2qMK6Z6iO9ZXJoXHkajr5QK1Osl/JYNHKIioFP\nAgMBAAGjggEjMIIBHzAJBgNVHRMEAjAAMBEGCWCGSAGG+EIBAQQEAwIGQDAzBglg\nhkgBhvhCAQ0EJhYkT3BlblNTTCBHZW5lcmF0ZWQgU2VydmVyIENlcnRpZmljYXRl\nMB0GA1UdDgQWBBQMLzyw2OjWg5gEc4pnhiGuo54fRzCBhQYDVR0jBH4wfIAUD9eD\nvQ5/CzQId3Szj35Qe1MvrXehYKReMFwxCzAJBgNVBAYTAlVTMQ4wDAYDVQQIDAVU\nZXhhczEPMA0GA1UEBwwGQXVzdGluMRMwEQYDVQQKDApXaWdXYWcgSW5jMRcwFQYD\nVQQDDA5XaWdXYWcgUm9vdCBDQYICEAAwDgYDVR0PAQH/BAQDAgWgMBMGA1UdJQQM\nMAoGCCsGAQUFBwMBMA0GCSqGSIb3DQEBCwUAA4ICAQCBZeMKx9fGRZXJZdjF9rtz\nMiN5szgDkQ/JSO/ixwgreDTgVDj+WVpaRuvBndkUG3oZmApreXqsCLobK4R9TSOp\nC0og8rI6+cP3wNelHNpczPJTCsSPHtT96QIuVG+p9pjSpOVYydLHv2D540ktxrTD\nC8MuKHvM1dpLGNcm5FSFwLjC2UJrPch9ZUyHE5EBaPSEE/xd5LlrlfLfLmGdGfRQ\nhYlM9KzH1sY7Xn5bnDhUa+hoyEwnsNk0V2GFSPtngf+p2irohfCBSRiICHwL1rT6\nVg4CwV67yuqzP0H6nHSqpyRB81thfR7EufpUxg0bJBEPewRzWwZe1COGJDGTGL9p\nvOl9/YrJRn3FT0YFcp8GTzlr+d+jUmMCkG7H/ZevMG8rY6LZEa5PMlK6jmzsmnIC\n9Hpw4rEiqf35/2NA0DAMhrMqslNXrVL8SEwL/FRCmd/s49PzIZvwaRs7Pdk15DqD\n24Ff9NlddGYsITy25mXLIBfibYky4v+XqFM3Ij4s1J23vbdMFIJO+M4IPRd/dVuA\nefEvFQQfqB1kiV8zi1VF46I9FJp2wzcnI6RNfaL4S+V8Ei+LghRRlCxSUXAIa/D+\nWJo+mTKuyvXRSNZsgt0N+kv7cNgbjuq7Eve5fBTiYVCshF56QN/2kIMA+eCA/1Es\nPx/Vcg5Lo+X9LEy4vx8yRw==\n-----END CERTIFICATE-----"
clouds_cloudURL["fsg"]="https://fsg-cloud.wigwag.io"
clouds_devicejsCloudURL["fsg"]="https://fsg-devicejs.wigwag.io"
clouds_devicedbCloudURL["fsg"]="https://fsg-devicedb.wigwag.io"

clouds_ssl_ca_ca["devcloud"]="-----BEGIN CERTIFICATE-----\nMIIFnjCCA4agAwIBAgIJALK9uBsr+g83MA0GCSqGSIb3DQEBCwUAMFwxCzAJBgNV\nBAYTAlVTMQ4wDAYDVQQIDAVUZXhhczEPMA0GA1UEBwwGQXVzdGluMRMwEQYDVQQK\nDApXaWdXYWcgSW5jMRcwFQYDVQQDDA5XaWdXYWcgUm9vdCBDQTAeFw0xNjA2MDEy\nMDM5MjFaFw0zNjA1MjcyMDM5MjFaMFwxCzAJBgNVBAYTAlVTMQ4wDAYDVQQIDAVU\nZXhhczEPMA0GA1UEBwwGQXVzdGluMRMwEQYDVQQKDApXaWdXYWcgSW5jMRcwFQYD\nVQQDDA5XaWdXYWcgUm9vdCBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC\nggIBALc+N4Mh1t8bDezX27BMAttTI/jfUiDfjeNb5w9F1T3bVg8rp1Ov8BIltAVU\nyqJnM+fvI/rwYwFRPMZY7zW8X1oSvgtKarsPqCZR2QJiv0cTSi/3gPOSunwIT4W7\nBnLAJhy3RoYhhxApmGyiUOcOMzgB3rlEQLk7DbaBf6SN99ONuarRjuzVOvyaFOtN\n549DM7HoS0EM7H6iXbJ5O6jHKi62ikW8KmUQhwjn165A0GPM1L90xmdGYSvsb4z3\nj/A0eewaEFlwBqpbgqd+JFqRiSTekh7a99/V8CJN8LM8wUZRbUZeMxaoTikBHSS2\nXpzBE7IeOU+nuGzPaqEt/7FyuVTRqcIljCLg2JwWDunXSMQS9BjnrCeyXfXYjHzq\n+A56Zbxh02dv6af+sPOQU+MqInTzigdVAo48tUmMWEIRjy40LDUPpzCTY9u/OGKM\nwDwCi41EaVMzxt4O2jkMRdZtimxrGzSHhJ8lLYvjNL5VN5IkLMSqxP8nZQhempfC\nW6DIaXLpp47WrrM7yYy4xQKRvcOQgjYjyoHKsZhvAVMHQlgJbmFy5pkQ5fFMeF69\n8IY+fO1L+4NKyXjxwrx4qsYVlpdsdq1Gq3GZLFRZK5+eWz1B+jfvByd7rJgPquln\ns0i0dQTmdArgM7pfbY0q5XQQ9FZQKXXeFT87RmIrQYJVS95DAgMBAAGjYzBhMB0G\nA1UdDgQWBBT7LAJkl2A4kJDKW0cHcaOJGs1g4jAfBgNVHSMEGDAWgBT7LAJkl2A4\nkJDKW0cHcaOJGs1g4jAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAN\nBgkqhkiG9w0BAQsFAAOCAgEAKEkegYys0knM0hSM6FnqJ+VYSb6cZL22j8r+V7al\nDd+OxNHrWPFw8AShDvbHKCi9icG0oe6vMvKgVb8/4y2Gcl5pPsk7zUdYZAkYEEN9\ncHIYvi49U1An77gA0OH3CUjyrjnMUuvozrTstQYHZfcl6to3ZfZerkwXYXm6xpgJ\nmOqEhJ5v0DgcFjCoYMGbr5/G2Kw3t69jYRxK3BfV5ZNqU2ct2ZJeDhD1c6mGPncu\ntKZp222XZZ3UIOVGodc3o8Zo6DJTMgh6A2CKSh3bfD8VIS+IzAJG4XmW+Vw7ffRm\nsmRdRd9TFhBMerGN08TJw7QOO7j5aeT+eeTPExQTnJg5I3vosejxP/kx54CHDvmU\n78N3R8jV6FTf0q+C2/rjsWY4uPvs4HiI/KIQmaNUubrgZmyRubr5Zl2WLbzkUoui\nytL1xdkSCQg8+UW0uD+oKuZ/QJwWmrL+9McwZnWI2DpysHeQa2Uswo9nomtF4gfS\nnE/sZOvLdgJyzCYxvegsrzsenr3KjrA+lhrmiB/A1HlfBlYpWbJDkE+7Atcx62Xx\nz03bTpWcz6Geq4mmYK/JXMGPr39gkVi/Tp14uVcS9fRn30+zWO5y6xW09fHDsNCT\n4lO7Pxfh/qY/lMcb8aQaVbbwqfD+VpC/8UDrbo0niBatG33uIxEiSabpJe8elgGJ\nciE=\n-----END CERTIFICATE-----"
clouds_ssl_ca_intermediate["devcloud"]="-----BEGIN CERTIFICATE-----\nMIIFkTCCA3mgAwIBAgICEAAwDQYJKoZIhvcNAQELBQAwXDELMAkGA1UEBhMCVVMx\nDjAMBgNVBAgMBVRleGFzMQ8wDQYDVQQHDAZBdXN0aW4xEzARBgNVBAoMCldpZ1dh\nZyBJbmMxFzAVBgNVBAMMDldpZ1dhZyBSb290IENBMB4XDTE2MDYwMTIwNDUyMVoX\nDTI2MDUzMDIwNDUyMVowUzELMAkGA1UEBhMCVVMxDjAMBgNVBAgMBVRleGFzMRMw\nEQYDVQQKDApXaWdXYWcgSW5jMR8wHQYDVQQDDBZXaWdXYWcgSW50ZXJtZWRpYXRl\nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEArY6aTP1Pv2+KcXOj\nnb1Sln6ty+MJH/JKfzsh8UMQ0CXX9pEvVKdDBkA8zAHULxPvmwpNZI1VIZTH6ELK\n/C5EBFWQiiX37KvQ/C+hAZdOau/aLSVD4f9sdGKVUcFigNmLIyff4ltJ60qp6Zzi\ndG2aWGcNncmp8J8mryscZyAOAWtVm/niWoU5Q1siJYMDEnYaO/y3ypPlOxpzX15k\nlFnkwkTQAc97eKqF1xBFa7NEZQm7okO+RR9eFfT2ibb/kQHmI56cD74XDN/knkmk\nFS6F6m0jZ9CmrJw/K0nE2a4rAKhKY44Brnm+k57iD+6EMIL7i42n28z0R5lueDhu\nuAHdngNTreSePl+gX+CCX0IxgCnG0xj0FwDxZdpcSuqHDY/qFocsFDeuxUbYOtB1\n1n2HxJ4E7uFvrJ+UHW1bAZtecQd23Owetb3OevAAn+1NnNjF1wF6t05kxNjv0DSn\n0qP82T80jAI/TzIuZMdE88ykHYSoDEfj0f0WwowihT6rKQQWvH3bk7gds6GVOzh9\nLHxk+3Q+mkzixe6UN/VhpXq4nz1WewR1VfvY6rchi2q5vqFHhG/DcuRwNGfvbcjs\nbFz5K/PyicH4i2bXPJIjoulNv4aLOWQXil+3tzn8Uqv21SGqpswI6h6BTffMTeHu\n/0R8ffDW4k6r++j8SuqP4GaaqrsCAwEAAaNmMGQwHQYDVR0OBBYEFA/Xg70Ofws0\nCHd0s49+UHtTL613MB8GA1UdIwQYMBaAFPssAmSXYDiQkMpbRwdxo4kazWDiMBIG\nA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMA0GCSqGSIb3DQEBCwUA\nA4ICAQAMNF3iH3cEn2rMeb3C2pvvG4E4arbE9jW/lbo8a5+aWTlsJlKmDvHrpjkJ\nEEmizB716Ev0U51l+4aTvgXyBYRF3GhrgF64XJWinJQ7jc8DS5yGyGAruX87wgoq\nhL/xsmOVuOxt2ZkH9ev6xwkCHCO7Zp2jMpJAUq/p+4Uv9wxKB9/jDYhdypjgPxSP\nmPNqwlF1NQvILtOfQ0PEyVw+4Hki7alC3AD8IPbVN71rHdroASRyYqZWKfQicKIj\nwv1K6d+X9IvFy2sinHn+H0iCa1CD69oR96fCAz+seNcM1rvx8ctND9LD7wbq2DKN\nTrK0ROSrxXWdVFVn/YpkpCnQKnwPnnOqJ7Yaicw1toVfYnXfZe0ZExHLUoYlFVH6\nrIgTSsnYpLeAtuc/P4orF5LGmzNjob3rIv3vNJIyBEXnydz2aEEySIYZH1k7kaZa\n0TpeA6+Fgs0yqgI7Gdf/gV5jDq2wO7FVBR1eqZMkVI8FzKrffCYQeKWADbi/UQOJ\n+mm0WykSLkFXi+yE36ijjq9X2HxLceO9XQYTiNtenQ9+bZk526L35rVhxszPFCbX\nwPS0BDH1hHcabQMXTAHZYX2w8ddlCWd9KLHIkSntsjxkiDsQzcd6hdd0mvWSp34H\n9muRVbct5CXpPowSYuuzk8CJtxlckKIqnm59ScGgcPk1IhMQlw==\n-----END CERTIFICATE-----"
clouds_cloudURL["devcloud"]="https://devcloud.wigwag.io"
clouds_devicejsCloudURL["devcloud"]="https://devcloud-devicejs.wigwag.io"
clouds_devicedbCloudURL["devcloud"]="https://devcloud-devicedb.wigwag.io"


#===========================================================================================================================
#============================================================================================================+==============
# Libaries
#===========================================================================================================================
#===============================================================================================================+===========
#---------------------------------------------------------------------------------------------------------------------------
# math utils
#---------------------------------------------------------------------------------------------------------------------------

#/	Desc:	Takes an integer and oupts hex
#/	Ver:	.1
#/	$1:		decimal
#/	$2:		name1
#/	$3:		name1
#/	Out:	hex string 2 digit format
#/	Expl:	out=$(math_dec2hex 33)
math_dec2hex() {
	capture=$(echo "obase=16;ibase=10; $1" | bc)
	lencapture=${#capture}
	if [[ $lencapture -eq 1 ]]; then
		echo "0$capture"
	else
		echo "$capture"
	fi
} #end_math_dec2hex

#/	Desc:	Takes an hex and oupts integer
#/	Ver:	.1
#/	$1:		hex
#/	Out:	dec string
#/	Expl:	out=$(math_hex2dec 0x22)
math_hex2dec() {
	printf "%d\n" $1
} #end_math_hex2dec

#/	Desc:	converts hex 2 ascii
#/	Ver:	.1
#/	$1:		hex
#/	Out:	ascii
#/	Expl:	$out=(math_hex2ascii "0x20")
math_hex2ascii() {
	a=$(echo "$1" | sed s/0/\\\\/1)
	echo -en "$a"
	#echo $b
} #end_math_hex2ascii

#/	Desc:	converts a single ascii character to hex
#/	Ver:	.1
#/	$1:		ascii char
#/	Out:	hex
#/	Expl:	output=$(math_ascii2hex "a")
math_ascii2hex(){
	letterhex=$(echo "$1" | od -t x1 | xargs | awk '{print $2}')
	echo -en "$letterhex"
} #end_math_ascii2hex

#---------------------------------------------------------------------------------------------------------------------------
# logging utilities
#---------------------------------------------------------------------------------------------------------------------------

#/	Desc:	common bash logger
#/	global:	LogToTerm 	[0|*1] uses the terminal number instead of echo to post messages.  this gets around degubbing functions that return data via echo
#/	global:	LogToSerial [*0|1] logs to both kmesg and ttyS0, good for relay debugging
#/	global: LogToecho 	[*0|1] logs to stdout.  disabled by default
#/	global: LogToFile 	<file> logs to a file
#/ 	global:	loglevel 	suppresses output for anything below the level spefied.  Levels are: ["none", "error", "warn", "info", "verbose", "debug", "silly","func"],
#/	$1:		message level within these options: ["none", "error", "warn", "info", "verbose", "debug", "silly","func"],
#/	$2:		"the message"
#/	$3:		<ignore> special for a depricated function function call
#/	Out:	debug info on your screen
#/	Expl:	log "debug" "oh snarks, i got a problem"
THISTERM=$(tty)
	#echo "hi this term is $THISTERM"
	LogToTerm=1
	LogToSerial=0
	LogToecho=0
	LogToFile=""
	loglevel=info;
	NORM="$(tput sgr0)"
	BOLD="$(tput bold)"
	REV="$(tput smso)"
	UND="$(tput smul)"
	BLACK="$(tput setaf 0)"
	RED="$(tput setaf 1)"
	GREEN="$(tput setaf 2)"
	YELLOW="$(tput setaf 3)"
	BLUE="$(tput setaf 4)"
	MAGENTA="$(tput setaf 5)"
	CYAN="$(tput setaf 6)"
	WHITE="$(tput setaf 7)"
	ERROR="${REV}Error:${NORM}"
	log(){
		level=$1
		message=$2
		lineinfo=$3
		devK=/dev/kmesg
		devS0=/dev/ttyS0
	#echo -e "LogToEcho=$LogToecho\nLogToTerm=$LogToTerm\nLogToSerial=$LogToSerial\nLogtoFile=$LogToFile\n"
	#echo "log called: $level $message $lineinfo"
	if [[ "$THISTERM" = "not a tty" ]]; then
		LogToTerm=0;
	fi
	colorRay=(none error warn info verbose debug silly func);
	for i in "${!colorRay[@]}"; do
		if [[ "${colorRay[$i]}" = "${loglevel}" ]]; then
			loglevelid=${i};
		fi
	done
	if [[ "$LogToecho" -eq 1 ]]; then
		case $level in
			"none") ;;
"error") 		if [[ $loglevelid -ge 1 ]]; then echo -e "${RED}error:${NORM}\t$message"; fi; ;;
"warn")  		if [[ $loglevelid -ge 2 ]]; then echo -e "${YELLOW}warn:${NORM}\t$message"; fi ;;
"info")  		if [[ $loglevelid -ge 3 ]]; then echo -e "${WHITE}info:${NORM}\t$message"; fi ;;
"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo -e "${CYAN}verbose:${NORM}\t$message"; fi ;;
"debug")  		if [[ $loglevelid -ge 5 ]]; then echo -e "${MAGENTA}debug [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message"; fi ;;
"silly")  		if [[ $loglevelid -ge 6 ]]; then echo -e "${GREEN}silly [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message"; fi ;;	
"function")		if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message"; fi ;;	
"function2")	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func2 $lineinfo:${NORM}\t$message"; fi ;;	
esac
fi
if [[ "$LogToTerm" -eq 1 ]]; then
	case $level in
		"none") ;;
"error")		if [[ $loglevelid -ge 1 ]]; then echo -e "${RED}error:${NORM}\t$message" > "$THISTERM"; fi; ;;
"warn")  		if [[ $loglevelid -ge 2 ]]; then echo -e "${YELLOW}warn:${NORM}\t$message" > "$THISTERM"; fi ;;
"info")  		if [[ $loglevelid -ge 3 ]]; then echo -e "${WHITE}info:${NORM}\t$message" > "$THISTERM"; fi ;;
"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo -e "${CYAN}verbose:${NORM}\t$message" > "$THISTERM"; fi ;;
"debug")  		if [[ $loglevelid -ge 5 ]]; then echo -e "${MAGENTA}debug [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$THISTERM"; fi ;;
"silly")  		if [[ $loglevelid -ge 6 ]]; then echo -e "${GREEN}silly [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$THISTERM"; fi ;;	
"function")  	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$THISTERM"; fi ;;	
"function2") 	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func2 $lineinfo:${NORM}\t$message" > "$THISTERM"; fi ;;	
esac
fi
if [[ "$LogToSerial" -eq 1 ]]; then
	case $level in
		"none") ;;
"error")		if [[ $loglevelid -ge 1 ]]; then echo -e "${RED}error:${NORM}\t$message" > "$devK"; fi; ;;
"warn")  		if [[ $loglevelid -ge 2 ]]; then echo -e "${YELLOW}warn:${NORM}\t$message" > "$devK"; fi ;;
"info")  		if [[ $loglevelid -ge 3 ]]; then echo -e "${WHITE}info:${NORM}\t$message" > "$devK"; fi ;;
"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo -e "${CYAN}verbose:${NORM}\t$message" > "$devK"; fi ;;
"debug")  		if [[ $loglevelid -ge 5 ]]; then echo -e "${MAGENTA}debug [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$devK"; fi ;;
"silly")  		if [[ $loglevelid -ge 6 ]]; then echo -e "${GREEN}silly [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$devK"; fi ;;	
"function")  	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$devK"; fi ;;	
"function2") 	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func2 $lineinfo:${NORM}\t$message" > "$devK"; fi ;;	
esac
case $level in
	"none") ;;
"error")		if [[ $loglevelid -ge 1 ]]; then echo -e "${RED}error:${NORM}\t$message" > "$devS0"; fi; ;;
"warn")  		if [[ $loglevelid -ge 2 ]]; then echo -e "${YELLOW}warn:${NORM}\t$message" > "$devS0"; fi ;;
"info")  		if [[ $loglevelid -ge 3 ]]; then echo -e "${WHITE}info:${NORM}\t$message" > "$devS0"; fi ;;
"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo -e "${CYAN}verbose:${NORM}\t$message" > "$devS0"; fi ;;
"debug")  		if [[ $loglevelid -ge 5 ]]; then echo -e "${MAGENTA}debug [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$devS0"; fi ;;
"silly")  		if [[ $loglevelid -ge 6 ]]; then echo -e "${GREEN}silly [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$devS0"; fi ;;	
"function")  	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$devS0"; fi ;;	
"function2") 	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func2 $lineinfo:${NORM}\t$message" > "$devS0"; fi ;;	
esac
fi
if [[ "$LogToFile" != "" ]]; then
	case $level in
		"none") ;;
"error")		if [[ $loglevelid -ge 1 ]]; then echo -e "${RED}error:${NORM}\t$message" >> "$LogToFile"; fi; ;;
"warn")  		if [[ $loglevelid -ge 2 ]]; then echo -e "${YELLOW}warn:${NORM}\t$message" >> "$LogToFile"; fi ;;
"info")  		if [[ $loglevelid -ge 3 ]]; then echo -e "${WHITE}info:${NORM}\t$message" >> "$LogToFile"; fi ;;
"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo -e "${CYAN}verbose:${NORM}\t$message" >> "$LogToFile"; fi ;;
"debug")  		if [[ $loglevelid -ge 5 ]]; then echo -e "5${MAGENTA}debug [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" >> "$LogToFile"; fi ;;
"silly")  		if [[ $loglevelid -ge 6 ]]; then echo -e "${GREEN}silly [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" >> "$LogToFile"; fi ;;	
"function")  	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" >> "$LogToFile"; fi ;;	
"function2") 	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func2 $lineinfo:${NORM}\t$message" >> "$LogToFile"; fi ;;	
esac
fi
} #end_log

#---------------------------------------------------------------------------------------------------------------------------
# json utils, currently only importer
#---------------------------------------------------------------------------------------------------------------------------

JSON_INPUT=""
JSON_INPUT_LENGTH=""
JSON_DELINATION="_"
JSON_OUTFILE=""

PRIVATE_JSON_output_entry() {
	local one=${1//-/}
	echo "$one=\"$2\"" >> "$JSON_OUTFILE"
}

PRIVATE_JSON_parse_array() {
	local current_path="${1:+$1$JSON_DELINATION}$2"
	local current_scope="root"
	local current_index=0

	while [ "$chars_read" -lt "$JSON_INPUT_LENGTH" ]; do
		[ "$preserve_current_char" == "0" ] && chars_read=$((chars_read+1)) && read -r -s -n 1 c
		preserve_current_char=0
		c=${c:-' '}

		case "$current_scope" in
			"root") # Waiting for new object or value
case "$c" in
	'{')
PRIVATE_JSON_parse_object "$current_path" "$current_index"
current_scope="entry_separator"
;;
']')
return
;;
[\"tfTF\-0-9])
						preserve_current_char=1 # Let the parse value function decide what kind of value this is
						PRIVATE_JSON_parse_value "$current_path" "$current_index"
						preserve_current_char=1 # Parse value has terminated with a separator or an array end, but we can handle this only in the next while iteration
						current_scope="entry_separator"
						;;
						
					esac
					;;
					"entry_separator")
[ "$c" == "," ] && current_index=$((current_index+1)) && current_scope="root"
[ "$c" == "]" ] && return
;;
esac
done
}

PRIVATE_JSON_parse_value() {
	local current_path="${1:+$1$JSON_DELINATION}$2"
	local current_scope="root"

	while [ "$chars_read" -lt "$JSON_INPUT_LENGTH" ]; do
		[ "$preserve_current_char" == "0" ] && chars_read=$((chars_read+1)) && read -r -s -n 1 c
		preserve_current_char=0
		c=${c:-' '}

		case "$current_scope" in
			"root") # Waiting for new string, number or boolean
case "$c" in
					'"') # String begin
current_scope="string"
current_varvalue=""
;;
					[\-0-9]) # Number begin
current_scope="number"
current_varvalue="$c"
;;
					[tfTF]) # True or false begin
current_scope="boolean"
current_varvalue="$c"
;;
					"[") # Array begin
PRIVATE_JSON_parse_array "" "$current_path"
return
;;
					"{") # Object begin
PRIVATE_JSON_parse_object "" "$current_path"
return
esac
;;
			"string") # Waiting for string end
case "$c" in
					'"') # String end if not in escape mode, normal character otherwise
[ "$current_escaping" == "0" ] && PRIVATE_JSON_output_entry "$current_path" "$current_varvalue" && return
[ "$current_escaping" == "1" ] && current_varvalue="$current_varvalue$c"
;;
					'\') # Escape character, entering or leaving escape mode
current_escaping=$((1-current_escaping))
current_varvalue="$current_varvalue$c"
;;
					*) # Any other string character
current_escaping=0
current_varvalue="$current_varvalue$c"
;;
esac
;;
			"number") # Waiting for number end
case "$c" in
					[,\]}]) # Separator or array end or object end
PRIVATE_JSON_output_entry "$current_path" "$current_varvalue"
						preserve_current_char=1 # The caller needs to handle this char
						return
						;;
					[\-0-9.]) # Number can only contain digits, dots and a sign
current_varvalue="$current_varvalue$c"
;;
					# Ignore everything else
				esac
				;;
			"boolean") # Waiting for boolean to end
case "$c" in
					[,\]}]) # Separator or array end or object end
PRIVATE_JSON_output_entry "$current_path" "$current_varvalue"
						preserve_current_char=1 # The caller needs to handle this char
						return
						;;
					[a-zA-Z]) # No need to do some strict checking, we do not want to validate the incoming json data
current_varvalue="$current_varvalue$c"
;;
					# Ignore everything else
				esac
				;;
			esac
		done
} #end_PRIVATE_JSON_parse_value

PRIVATE_JSON_parse_object() {
	local current_path="${1:+$1$JSON_DELINATION}$2"
	local current_scope="root"

	while [ "$chars_read" -lt "$JSON_INPUT_LENGTH" ]; do
		[ "$preserve_current_char" == "0" ] && chars_read=$((chars_read+1)) && read -r -s -n 1 c
		preserve_current_char=0
		c=${c:-' '}

		case "$current_scope" in
			"root") # Waiting for new field or object end
[ "$c" == "}" ]  && return
[ "$c" == "\"" ] && current_scope="varname" && current_varname="" && current_escaping=0
;;
			"varname") # Reading the field name
case "$c" in
					'"') # String end if not in escape mode, normal character otherwise
[ "$current_escaping" == "0" ] && current_scope="key_value_separator"
[ "$current_escaping" == "1" ] && current_varname="$current_varname$c"
;;
					'\') # Escape character, entering or leaving escape mode
current_escaping=$((1-current_escaping))
current_varname="$current_varname$c"
;;
					*) # Any other string character
current_escaping=0
current_varname="$current_varname$c"
;;
esac
;;
			"key_value_separator") # Waiting for the key value separator (:)
[ "$c" == ":" ] && PRIVATE_JSON_parse_value "$current_path" "$current_varname" && current_scope="field_separator"
;;
			"field_separator") # Waiting for the field separator (,)
[ "$c" == ',' ] && current_scope="root"
[ "$c" == '}' ] && return
;;
esac
done
} #end_PRIVATE_JSON_parse_object

PRIVATE_JSON_STARTparse() {
	echo -e "#!/bin/bash\n" > .jsonOut
	chars_read=0
	preserve_current_char=0

	while [ "$chars_read" -lt "$JSON_INPUT_LENGTH" ]; do
		read -r -s -n 1 c
		c=${c:-' '}
		chars_read=$((chars_read+1))

		# A valid JSON string consists of exactly one object
		[ "$c" == "{" ] && PRIVATE_JSON_parse_object "" "" && return
        # ... or one array
        [ "$c" == "[" ] && PRIVATE_JSON_parse_array "" "" && return
        
   done
}


	#/	Desc:		parses a json file to something sourceable
#/	$1:			file.json
#/	$2:			output file
#/	Output: 	just the file specified in $2
#/	Example: 	json_toShFile ./wigwag/FACTORY/QRScan/cfg.json .jsn
#/				source .jsn
json_toShFile(){
	JSON_OUTFILE="$2"
	echo "" > $JSON_OUTFILE
	#log "debug" "myoutfile is $JSON_OUTFILE"
	JSON_INPUT=$(cat "$1")
	JSON_INPUT_LENGTH="${#JSON_INPUT}"
	PRIVATE_JSON_STARTparse "" "" <<< "${JSON_INPUT}"
} #end_json_toShFile

#---------------------------------------------------------------------------------------------------------------------------
# array library
#---------------------------------------------------------------------------------------------------------------------------

#/	Desc:	checks if an array contains an exact element
#/	Ver:	.1
#/	$1:		name passed array
#/	$2:		search text
#/	Out:	0|1
#/	Expl:	out=$(array_contains array string)
array_contains() { 
local array="$1[@]"
local seeking=$2
local in=0
for element in "${!array}"; do
	if [[ $element == $seeking ]]; then
		in=1
		break
	fi
done
echo $in
} #end_array_contains

#/	Desc:	copies a regular array
#/	Ver:	.1
#/	$1:		named from array
#/	$2:		named to array
#/	Out:	globally the named to array (no output)
#/	Expl:	array_copy from to
array_copy(){
	fromname="$1"
	toname="$2"
	local array="$fromname[@]"
	eval "$toname=()"
	for element in "${!array}"; do
		eval "$toname+=(\"$element\")"
	done
} #end_array_copy

#/	Desc:	private function that creates arrays from delimted list
#/	Ver:	.1
#/	$1:		named array
#/	$2:		list
#/	$3:		delimeter
#/	Out:	globally outputs the named array
#/	Expl:	PRIVATE_array_createFromGeneric "arrayname" "thelist" "delimeter"
PRIVATE_array_createFromGeneric(){
	namearray="$1"
	local list="$2"
	local delimeter="$3"
	IFS="$delimeter" read -r -a $namearray <<< "$list"
} #end_PRIVATE_array_createFromGeneric

#/	Desc:	creates array from a space list
#/	Ver:	.1
#/	$1:		named array
#/	$2:		list
#/	Out:	globally outputs the named array
#/	Expl:	array_createFromSpaceList "myray" "cats dogs planes"
array_createFromSpaceList(){
	PRIVATE_array_createFromGeneric "$1" "$2" " "
} #end_array_createFromSpaceList

#/	Desc:	creates array from a comma list
#/	Ver:	.1
#/	$1:		named array
#/	$2:		list
#/	Out:	globally outputs the named array
#/	Expl:	array_createFromSpaceList "myray" "cats,dogs,planes"
array_createFromCommaList(){
	PRIVATE_array_createFromGeneric "$1" "$2" ","
} #end_array_createFromCommaList

#---------------------------------------------------------------------------------------------------------------------------
# utils  associative array
#---------------------------------------------------------------------------------------------------------------------------

#/	Desc:	copies an assoicaitve array
#/	Ver:	.1
#/	$1:		named from array
#/	$2:		named to array
#/	Out:	globally the named to array (no output)
#/	Expl:	associativeArray_copy from to
associativeArray_copy(){
	fromname="$1"
	toname="$2"
	declare -n from="${fromname}"
	eval declare -g -A "${toname}"
	for key in "${!from[@]}"; do
		eval $toname["$key"]="${from["$key"]}"
	done
}

#/	Desc:	prints an assoicative array out to the screen
#/	Ver:	.1
#/	$1:		array to print
#/	$2:		name1
#/	$3:		name1
#/	Out:	printed array
#/	Expl:	associativeArray_print myray
associativeArray_print(){
	declare -n theArray=$1
	echo -en "$1 (${#theArray[@]} records)\n-------------------------------------------------------------------------------------------------------------------------------------------\n"
	for KEY in "${!theArray[@]}"; do
		len=${#KEY}
		tabcount=$(( 5 - ( $len / 4 ) ))
		echo -en "\t$KEY:"
		for (( i = 0; i < $tabcount; i++ )); do
			echo -en "\t"
		done
		echo -en "-${theArray[$KEY]}\n"
	done
  #   echo -en "\n"
  #   outtable="KEY VALUE\n"
  # for KEY in "${!theArray[@]}"; do
  #   VALUE="${theArray[$KEY]}"
  #   outtable="$outtable""$KEY '$VALUE'\n"
  # done
  # echo -e $outtable | column -t
} #end_associativeArray_print

#---------------------------------------------------------------------------------------------------------------------------
# string libary utils
#---------------------------------------------------------------------------------------------------------------------------

#/	Desc:	removes all newlines from a string
#/	Ver:	.1
#/	$1:		string
#/	Out:	string
#/	Expl:	out=$(string_removeAllNewlines string)
string_removeAllNewlines(){
	echo "${1//'\n'/}" 
} #end_string_removeAllNewlines

#/	Desc:	replaces first instance of string with a string
#/	Ver:	.1
#/	$1:		full string
#/	$2:		search string
#/	$3:		replacement string
#/	Out:	full string
#/	Expl:	$out=$(string_replaceFirst fullstring search replace)
string_replaceFirst(){
	local "instr"="$1"
	local "searchfor"="$2"
	local "replacewith"="$3"
	echo ${instr/$searchfor/$replacewith}
} #end_string_replaceFirst

#/	Desc:	replaces all mattching strings with repacement string within string
#/	Ver:	.1
#/	$1:		full string
#/	$2:		search string
#/	$3:		replacement string
#/	Out:	full string
#/	Expl:	$out=$(string_replaceFirst fullstring search replace)
string_replaceAll(){
	local "instr"="$1"
	local "searchfor"="$2"
	local "replacewith"="$3"
	echo ${instr//$searchfor/$replacewith}
} #end_string_replaceAll

#-----------------------------------------------------------------------------------------------------------------------
#  utils i2c
#-----------------------------------------------------------------------------------------------------------------------

#/	Desc:	erases the page called
#/	Ver:	.1
#/	$1:		page
#/	Out:	n/a
#/	Expl:	i2c_erasePage 0x50
i2c_erasePage(){
	local page="$1"
	local erasei
	for erasei in {0..255}; do 
	i2cset -y 1 $page $erasei 0xff b; 
done
} #end_i2c_erasePage

#/	Desc:	erases one character with 0xFF
#/	Ver:	.1
#/	$1:		page
#/	$2:		posisition
#/	$3:		
#/	Out:	n/a
#/	Expl:	i2c_eraseOne 0x50 21
i2c_eraseOne(){
	local page="$1"
	local position="$2"
	i2cset -y 1 $page $position 0xff b; 
} #end_i2c_eraseOne

#/	Desc:	grabs one character from the Eerpom
#/	Ver:	.1
#/	$1:		page
#/	$2:		position
#/	Out:	outputs the character in native format
#/	Expl:	hex=(i2c_getOne 0x50 2)
i2c_getOne(){
	local page="$1"
	local position="$2"
	log silly "i2cget -y 1 $page $position b"
	a=$(i2cget -y 1 $page $position b) 
	echo $a
} #end_i2c_getOne

#/	Desc:	sets one character via the i2cset command
#/	Ver:	.1
#/	$1:		page
#/	$2:		position
#/	$3:		hexvalue
#/	Out:	n/a
#/	Expl:	i2c_setOne 0x50 20 0x33
i2c_setOne(){
	local page="$1"
	local position="$2"
	local hexvalue="$3"
	log silly "i2cset -y 1 $page $position $hexvalue"
	a=$(i2cset -y 1 $page $position $hexvalue)
	#echo $a
} #end_i2c_setOne

#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------
# getopts helpper utilities for cli options
#---------------------------------------------------------------------------------------------------------------------------

#/	Desc:	Gathers all the keys from the menu system and builds a proper string for getopts
#/	Ver:	.1	
#/	Out:	echo - switch_conditions
#/	Expl:	switch_conditions=$(clihelp_switchBuilder)
clihelp_switchBuilder(){
	#shellcheck disable=SC2154
	for KEY in "${!hp[@]}"; do
		:
		VALUE=${hp[$KEY]}
		numcheck="${KEY:1:1}"
		skip=false
		if [[ "$numcheck" =~ ^[0-9]+$ ]]; then
			skip=true
		fi
		double=""
		if [[ ${#KEY} -gt 1 ]]; then
			double=":"
			dKEY="${KEY:0:1}"
		else
			dKEY=$KEY
		fi
		if [[ $KEY != "description" && $KEY != "useage" && $skip != true ]]; then
			myline=$myline$dKEY$double
		fi
	done
	echo "$myline"
} #end_clihelp_switchBuilder


#/	Desc:	Generates a menu based on a named template system
#/	Ver:	.1
#/  Global: declare -A hp=() assoiative array of switches
#/			exects an associateve array named hp.
#/			hp nomenclature hp[x] where x represents a switch
#/			and where hp[xx] represents a switch and varriable
#/	$1:		[error text]  OPTIONAL
#/	$2:		name1
#/	$3:		name1
#/	Out:	a help text for the cli
#/	Expl:	clihelp_displayHelp
clihelp_displayHelp(){
	if [[ $1 != "" ]]; then
		echo -e "\nERROR: ${REV}${BOLD}$1${NORM}"
	fi
	echo -e \\n"Help documentation for ${BOLD}$0${NORM}"
	echo -e "${hp[description]}"
	echo -e "----------------------------------------------------------------------------------------"
	echo -e "${BOLD}Basic usage:${NORM}${BOLD} $0 ${NORM} ${hp[useage]}"
	etext=""
	for KEY in "${!hp[@]}"; do
		:
		VALUE=${hp[$KEY]}
		numcheck="${KEY:1:1}"
		skip=false
		if [[ "$numcheck" =~ ^[0-9]+$ ]]; then
			skip=true
			if [[ ${KEY:0:1} = "e" ]]; then
				etext=$etext"${UND}${BOLD} Example:${NORM} $VALUE\n"
			fi
		fi
		if [[ ${#KEY} -gt 1 ]]; then
			dKEY="${KEY:0:1}"
		else
			dKEY=$KEY
		fi
		if [[ $KEY != "description" && $KEY != "useage" && $skip != true ]]; then
			switches=$switches"${BOLD}-$dKEY${NORM} $VALUE\n"
		fi
	done  
	echo -e "$switches"  | sort -n -k1
	echo -e "$etext\n"
	exit 1
} #end_clihelp_displayHelp

#===========================================================================================================================
#============================================================================================================+==============
# Main Operations
#===========================================================================================================================
#===============================================================================================================+===========

buildreturn(){
	local hex="$1"
	local RET="$2"
	local output="$3"
	local delimeter="$4"
	if [[ $output == "decimal" ]]; then
		var=$(math_hex2dec $hex)
	elif [[ $output == "ascii" ]]; then
		var=$(math_hex2ascii $hex)
	elif [[ $output == "hex-stripped" ]]; then
		var=`expr "$hex" : '^0x\([0-9a-zA-Z]*\)'`	
	elif [[ $output == "dec" ]]; then
		var=$(math_hex2dec $hex);		
	else
		var=$hex
	fi
	if [[ $RET == "" ]]; then
		RET="$var"
	else
		RET+=$delimeter"$var"
	fi
	echo "$RET"
}

getRangeQuickTemp(){
	getRange $@
}

getRangeQuick(){
	#eeprog /dev/i2c-1 0x50 -r 0x0:64 -f
	local page=$1
	local start=$2
	local end=$3
	local output=$4
	local delimeter=$5
	local RET=""
	local pnum;
	local dev="/dev/i2c-1"
	local oldend=$end;
	end=$(($end -$start + 1));
	#echo -e "getRAnge\npage: $page\nstart: $start\noldend: $oldend\nend: $end\noutput: $output\ndelimeter: $delimeter\n"
	if [[ "$platform" != "softRelay" ]]; then
		RET=$(eeprog -q -f -r $start:$end $dev $page) 
		RET=$(echo "$RET" | tr -cd "[:print:]")
	else
		datapull=$(database_get $fetchfield)
		datapullc=0;
		log silly "$start $end $datapull"
		for ((pnum = $start ; pnum <= $end ; pnum++)); do
			hex=$(echo ${datapull:$datapullc:4})
			log silly "'$hex'"
			if [[ "$hex" = "" ]]; then
				break;
			fi
			datapullc=$(( $datapullc + 4 ))
			RET=$(buildreturn "$hex" "$RET" $output $delimeter)
		done
	fi
	echo "$RET"
} #end_getRange


#/	Desc:	pulls a range from the eeprom
#/	$1:		start (using position, e.g. 2=2nd character in eeprom)
#/	$2:		end (using position)
#/	Out:	output [ascii|decimal|hex|hex-stripped]
#/	Expl:	SN=$(grabRange 0 9 "ascii" "")
getRange() {
	local page=$1
	local start=$2
	local end=$3
	local output=$4
	local delimeter=$5
	local RET=""
	local pnum;
	if [[ "$platform" != "softRelay" ]]; then
		for ((pnum = $start ; pnum <= $end ; pnum++ )); do
			h=$(printf "%#x\n" $pnum)
			log silly "i2c_getOne $page $pnum"
			hex=$(i2c_getOne $page $h)
			if [[ "$hex" = "0xff" ]]; then
				break;
			fi
			RET=$(buildreturn "$hex" "$RET" "$output" "$delimeter")
		done
	else
		datapull=$(database_get $fetchfield)
		datapullc=0;
		log silly "$start $end $datapull"
		for ((pnum = $start ; pnum <= $end ; pnum++)); do
			hex=$(echo ${datapull:$datapullc:4})
			log silly "'$hex'"
			if [[ "$hex" = "" ]]; then
				break;
			fi
			datapullc=$(( $datapullc + 4 ))
			RET=$(buildreturn "$hex" "$RET" $output $delimeter)
		done
	fi
	echo "$RET"
} #end_getRange

getFile(){
	local fieldin="$1"
	local output="$2"
	local firstpass=1;
	local stringout=""
	local readfile="$softstoragepath/${fields_page[$fieldin]}"
	if [[ -e $readfile ]]; then
		readarray -t cer < $readfile
		for fileline in "${cer[@]}"; do
			if [[ $firstpass -eq 1 ]]; then
				stringout="$fileline"
				firstpass=0
			else
				stringout="$stringout"\\n"$fileline"
			fi
		done
	fi
	echo "$stringout"
}

setRange() {
	local page="$1"
	local start="$2"
	local end="$3"
	local inputType="$4"
	local fieldData="$5"
	local fieldDataInputType="$6"
	local setfield="$7"
	local pnum;
	local letter;
	local lettercounter=0;
	local loopwalk
	local newstring=""
	#convert everything to hex
	fieldDatasize=${#fieldData}
	case $fieldDataInputType in
		"ascii") 
for (( pnum = 0 ; pnum < $fieldDatasize ; pnum++ )); do
	letter=$(echo ${fieldData:$pnum:1})
	letterhex="0x"$(math_ascii2hex $letter)
	newstring="$newstring$letterhex"
done
;;
"hex-stripped")
newstring="0x"$(echo "$fieldData" | sed 's/.\{2\}/&0x/g')
;;
"hex-colon")
newstring="0x"$(echo "$fieldData" | sed 's/:/0x/g')
;;
"dec-comma")
IFS="," read -r -a commaray <<< "$fieldData"
for c in ${commaray[@]}; do
	newstring="$newstring""0x"$(math_dec2hex $c);
done
;;
"decimal")
newstring="0x"$(math_dec2hex $fieldData);
;;
"hex")
newstring=$fieldData;
;;
esac
fieldDataInputType="hex";
thenewstringsize=${#newstring}
	#log debug "$newstring $fieldDataInputType"
	fieldDatasize=$(( $thenewstringsize / 4 ))
	fieldlengthsize=$(( $end + 1 - $start ))
	#log debug " $fieldlengthsize $fieldDatasize"
	if [[ $fieldlengthsize -eq 256 && $fieldDatasize -lt 256 ]]; then
		end=$(( $fieldDatasize - 1 ));
	elif [[ $fieldDatasize -ne $fieldlengthsize ]]; then
		log error "Failing before write your string: $setfield=$fieldData ($newstring) size = $fieldDatasize and the slot size is $fieldlengthsize  [hint: look at the -m flag]"
		exit
	fi
	if [[ "$platform" != "softRelay" ]]; then
		for (( pnum = $start ; pnum <= $end ; pnum++ )); do
			pnumhex=$(printf "%#x\n" $pnum)
			#log debug "current lettercounter $lettercounter before + 2"
			lettercounter=$(( $lettercounter + 2 ));
			#log debug "current lettercounter $lettercounter after + 2"
			letterhex="0x"$(echo ${newstring:$lettercounter:1})
			lettercounter=$(( $lettercounter + 1 ));
			#log debug "current lettercounter $lettercounter after + 2"
			letterhex="$letterhex"$(echo ${newstring:$lettercounter:1})
			letter=$(math_hex2ascii $letterhex)
			lettercounter=$(( $lettercounter + 1 ));
			#log silly "saving $letter ($letterhex) to page $page, position $pnumhex"
			i2c_setOne "$page" "$pnumhex" "$letterhex" 
		done
	else
		database_set $setfield $newstring
	fi
} #end_getRange


setFile(){
	local fieldin="$1"
	local output="$2"
	local fielddata="$3"
	local firstpass=1;
	local stringout=""
	echo -en "$fielddata" > $output
}

delFile(){
	thefilein="$1"
	if [[ -e "$thefilein" ]]; then
		rm -rf "$thefilein"
	fi
}

getField(){
	fetchfield="$1"
	thisfieldtype="$2"
	dojsonout="$3"
	delimeterchar=""
	local retdata=""
	if [[ "$thisfieldtype" = "hex-colon" ]]; then
		thisfieldtype="hex-stripped"
		delimeterchar=":"
	elif [[ "$thisfieldtype" = "dec-comma" ]]; then
		thisfieldtype="dec"
		delimeterchar=","
	fi
	log silly "getField called with '$fetchfield' '$thisfieldtype' '$delimeterchar'"
	if [[ "$fetchfield" = "ssl_client_certificate" || "$fetchfield" = "ssl_client_key" || "$fetchfield" = "ssl_server_certificate" || "$fetchfield" = "ssl_server_key" || "$fetchfield" = "ssl_ca_ca" || "$fetchfield" = "ssl_ca_intermediate" ]]; then
		data=$(getFile "$fetchfield");
		# echo $fetchfield
		# echo "$data"
		# echo "NOOONONONONONONONONOONNONONONO"
		# exit
		if [[ $dojsonout -eq 1 ]]; then
			if [[ "$data" != "" ]]; then
				#echo $fetchfield
				retdata=${fields_start[$fetchfield]}\"$data\"${fields_end[$fetchfield]}
			fi
		else

			retdata="$data"
		fi
	else
		if [[ ${fields_storetype[$fetchfield]} != "ascii" || $thisfieldtype != "ascii" ]]; then
			data=$(getRange ${fields_page[$fetchfield]} ${fields_start[$fetchfield]} ${fields_end[$fetchfield]} $thisfieldtype "$delimeterchar")
		else
			data=$(getRangeQuick ${fields_page[$fetchfield]} ${fields_start[$fetchfield]} ${fields_end[$fetchfield]} $thisfieldtype "$delimeterchar")
		fi
		if [[ $dojsonout -eq 1 ]]; then

			retdata="{ \"$fetchfield\":\"$data\" }"
		else
			retdata=$data
		fi
	fi
	# if [[ "$retdata" = "" ]]; then
	# 	etdata=
	# else
	# 	echo ""
	# fi
	if [[ "$nonewline" -eq 1 ]]; then
		#echo "here I am"
		echo -n "$retdata"
	else
		echo "$retdata"
	fi
}

setField(){
	local setfield="$1"
	local thestring="$2"
	local fieldDataInputType="$3"
	if [[ $fieldDataInputType = "file" ]]; then
		setFile "$setfield" "$softstoragepath/${fields_page[$setfield]}" "$thestring"
	else
			#log debug "${fields_page[$setfield]} ${fields_start[$setfield]} ${fields_end[$setfield]} ignoreme $thestring $fieldDataInputType"
			setRange ${fields_page[$setfield]} ${fields_start[$setfield]} ${fields_end[$setfield]} "ignoreme" "$thestring" "$fieldDataInputType" "$setfield"
		fi
		local len=${#thestring}
		if [[ $len -gt 25 ]]; then
			thestring="-omitted len > 25"
		fi
		log info "set field:\t$setfield\t$thestring ($fieldDataInputType)"
	}


	mountFileStorage(){
		mount "$1" "$2" > /dev/null 2>&1
	}

	createSoftStoragePath(){
		local path="$1"
		if [[ ! -d "$path" ]]; then
			mkdir -p "$path" >> /dev/null
		fi
	}

	eraseSoftStoragePath(){
		local path="$softstoragepath"
		if [[  -d "$path" && "$path" != "" && "$path" != "/" ]]; then
			rm -rf "$path"
			createSoftStoragePath "$path"
		fi
	}

	setJson(){
		local infile="$1"
		local outfile="/tmp/jsonout.sh"
		local outfileMU="/tmp/jsonoutMU.sh"
		local outfileMO="/tmp/jsonoutMO.sh"
		local f;
		if [[ $donterase -ne 1 ]]; then
			log warn "erasing all data stores to prevent errors"
			eraseit all
		fi
		json_toShFile "$infile" "$outfile"
		if [[ "$automunge" != "" ]]; then
			ssl_ca_ca="${clouds_ssl_ca_ca[$automunge]}"
			ssl_ca_intermediate="${clouds_ssl_ca_intermediate[$automunge]}"
			cloudURL="${clouds_cloudURL[$automunge]}"
			devicejsCloudURL="${clouds_devicejsCloudURL[$automunge]}"
			devicedbCloudURL="${clouds_devicedbCloudURL[$automunge]}"
		fi

		if [[ "$mundgeUnderrideFile" != "" ]]; then
			if [[ "$mundgeUnderrideFile" = *".sh" ]]; then
				source "$mundgeUnderrideFile"
			else
				json_toShFile "$mundgeUnderrideFile" "$outfileMU"
				source "$outfileMU"
			fi
		fi
		if [[ "$mundgeUndertext" != "" ]]; then
			IFS="," read -r -a MOray <<< "$mundgeUndertext"
			for mungepair in ${MOray[@]}; do
				IFS="=" read -r -a MK <<< "$mungepair"
				eval "${MK[0]}=${MK[1]}"
			done
		fi
		source "$outfile"
		if [[ "$ethernetMAC_0" != "" ]]; then
			ethernetMAC=""
			for qi in {0..5}; do
				val="ethernetMAC_$qi"
				val=${!val}
				if [[ $qi -eq 0 ]]; then
					ethernetMAC="$val"
				else
					ethernetMAC="$ethernetMAC,$val"
				fi
			done
		fi
		if [[ "$sixBMAC_0" != "" ]]; then
			sixBMAC=""
			for qi in {0..7}; do
				val="sixBMAC_$qi"
				val=${!val}
				if [[ $qi -eq 0 ]]; then
					sixBMAC="$val"
				else
					sixBMAC="$sixBMAC,$val"
				fi
			done
		fi
		if [[ "$mundgeOveridefile" != "" ]]; then
			if [[ "$mundgeOveridefile" = *".sh" ]]; then
				source "$mundgeOveridefile"
			else
				json_toShFile "$mundgeOveridefile" "$outfileMO"
				source "$outfileMO"
			fi
		fi
		if [[ "$mundgeOvertext" != "" ]]; then
			IFS="," read -r -a MOray <<< "$mundgeOvertext"
			for mungepair in ${MOray[@]}; do
				IFS="=" read -r -a MK <<< "$mungepair"
				eval "${MK[0]}=${MK[1]}"
			done
		fi
		for field in "${fields[@]}"; do
			f=("${!field}")
		#echo "our $field ($f)"
		if [[ "$f" != "" ]]; then
			#echo "$field ($f)"
			thisstoretype="${fields_storetype[$field]}";
			#log debug "setField $field $f $thisstoretype"
			setField "$field" "$f" "$thisstoretype"
		else
			if [[ $field = "ssl_ca_ca" || $field = "ssl_ca_intermediate" ]]; then
				hint=" [hint: look at the -a flag]"
			fi
			log warn "Missing field:\t$field $hint"
		fi
	done
}

i2cdump(){
	i2cdump -y 1 0x50
	i2cdump -y 1 0x51
	i2cdump -y 1 0x52
	i2cdump -y 1 0x53
}

setit(){
	setfield="$1"
	setdata="$2"
	setfieldtype="$fieldtype"
	if [[ "$setfield" = *".json" ]]; then
		setJson "$setfield"
	elif [[ $(array_contains fields $setfield ) -eq 1 ]]; then
		setField "$setfield" "$setdata" "$fieldtype"
	else
		clihelp_displayHelp "field: $setfield is not valid"
	fi
}

getit(){
	fetchfield="$1"
	thesome="$2"
	fieldDataOutputType="$fieldtype"
	#log debug "fetchfield '$fetchfield'"
	if [[ "$fetchfield" = "all"  ]]; then
		dumpall
	elif [[ "$fetchfield" = "some" ]]; then
		dumpall "$thesome"
	elif [[ $(array_contains fields $fetchfield ) -eq 1 ]]; then
		#echo "getit called $1 $fieldtype"
		getField "$1" "$fieldtype" "$jsonoutput"
	else
		clihelp_displayHelp "field: $fetchfield is not valid"
	fi
}

eraseit(){
	what="$1"
	local eraseablestring="";
	local eEE=0;
	local eSSP=0;
	if [[ "$what" = "all" ]]; then
		eEE=1
		eSSP=1
	elif [[ "$what" = "eeprom" ]]; then
		eEE=1;
	elif [[ "$what" = "softstore" ]]; then
		eSSP=1
	elif [[ $(array_contains fields $what ) -eq 1 ]]; then
		if [[ ${fields_storetype[$what]} != "file" ]]; then
			lengthd=$(( ${fields_end[$what]} + 1 - ${fields_start[$what]} ))
			for (( i = 0; i < $lengthd; i++ )); do
				eraseablestring="$eraseablestring"0xFF
			done
			setRange ${fields_page[$what]} ${fields_start[$what]} ${fields_end[$what]} "ignoreme" "$eraseablestring" "hex" "$what"
		else
			delFile "$softstoragepath/${fields_page[$what]}"
		fi
	fi
	if [[ $eEE -eq 1 ]]; then
		if [[ $haveRealEEprom -eq 1 ]]; then
			for KEY in "${!iccpages[@]}"; do
				mVAL="${iccpages[$KEY]}"
				log info "Erasing EEPROM Location $KEY: [$mVAL]"
				i2c_erasePage $mVAL
			done
		else
			database_erase
		fi
	fi
	if [[ $eSSP -eq 1 ]]; then
		eraseSoftStoragePath
	fi
}

installit(){
	local instcmd="$1"
	local opt2="$2"
	local fileout="$3"
	local fileoutdir=$(dirname $fileout)
	mkdir -p $fileoutdir

	if [[ $jsonoutput -ne 1 ]]; then
		if [[ "$fileout" = *".json" ]]; then
			jsonoutput=1
		fi
	fi

	if [[ "$1" = "all" ]]; then
		outfromdumpall=$(dumpall)
		echo "$outfromdumpall" > "$fileout"
		mkdir -p "$opt2"
		cp $softstoragepath/*.pem $opt2/

	elif [[ "$1" = "field" ]]; then
		echo "field" "$2" "$fileout" "$localtype"
	fi
}

softeeprom(){
	:
	#someday: http://stackoverflow.com/questions/7290816/how-to-overwrite-some-bytes-of-a-binary-file-with-dd
}

dumpout="";
secondtrip=0;
builddumpout(){
	tag="$1"
	strin="$2"
	if [[ $jsonoutput -eq 0 ]]; then
		dumpout="$dumpout$tag=$strin\n"
			# echo "$dumpout"
		else
			if [[ $ssl -ne 1 ]]; then
				if [[ $secondtrip -eq 0 ]]; then
					dumpout="{"
					secondtrip=1
					dumpout="$dumpout \"$tag\":$strin"
				else
					dumpout="$dumpout, \"$tag\":$strin"
				fi
			fi
		fi
	}

	dumpall(){
		q='"'
		qssl='"ssl'
		qssl2='"sslnonewline'
		qclient='"client'
		qserver='"server'
		qkey='"key'
		qcertificate='"certificate'
		qintermediate='"intermediate'
		qca='"ca'
		ssltemplate="\"\$qssl\"\$q: { \"\$qclient\"\$q: {\"\$qkey\"\$q: \"\$q\$ssl_client_key\"\$q,\"\$qcertificate\"\$q: \"\$q\$ssl_client_certificate\"\$q},\"\$qserver\"\$q: {\"\$qkey\"\$q: \"\$q\$ssl_server_key\"\$q,\"\$qcertificate\"\$q: \"\$q\$ssl_server_certificate\"\$q},\"\$qca\"\$q: {\"\$qca\"\$q: \"\$q\$ssl_ca_ca\"\$q,\"\$qintermediate\"\$q: \"\$q\$ssl_ca_intermediate\"\$q}}"
		ssltemplate2="\"\$qssl2\"\$q: { \"\$qclient\"\$q: {\"\$qkey\"\$q: \"\$q\$ssl_client_key_2\"\$q,\"\$qcertificate\"\$q: \"\$q\$ssl_client_certificate_2\"\$q},\"\$qserver\"\$q: {\"\$qkey\"\$q: \"\$q\$ssl_server_key_2\"\$q,\"\$qcertificate\"\$q: \"\$q\$ssl_server_certificate_2\"\$q},\"\$qca\"\$q: {\"\$qca\"\$q: \"\$q\$ssl_ca_ca_2\"\$q,\"\$qintermediate\"\$q: \"\$q\$ssl_ca_intermediate_2\"\$q}}"
		secondtrip=0;
		if [[ "$1" = "" ]]; then
			array_copy fields loopfields
		else
			array_createFromCommaList loopfields "$1"
		fi
		for field in ${loopfields[@]}; do
			ssl=0
			if [[ "$field" = "ssl_client_certificate" || "$field" = "ssl_client_key" || "$field" = "ssl_server_certificate" || "$field" = "ssl_server_key" || "$field" = "ssl_ca_ca" || "$field" = "ssl_ca_intermediate" ]]; then
				temp=$(getFile "$field");
			#log debug "my $temp"
			output34=$(string_removeAllNewlines "$temp")
			eval "$field=\$temp"
			f2=$field"_2"
			eval "$f2=\"\$output34\""
			ssl=1
			# if [[ $jsonoutput -eq 0 ]]; then
			# 	out="$out$field $strin\n"
			# fi
			if [[ $jsonoutput -eq 0 ]]; then
				builddumpout "$field" "\"$temp\""
				builddumpout "$f2" "\"$output34\""
			fi
		elif [[ "$field" = "ethernetMAC" ]]; then
			temp="["$(getField "$field" "dec-comma" 0)"]"
			builddumpout "$field" "$temp"
			temp1="\""$(getField "ethernetMAC" "hex-colon" 0)"\""
			builddumpout "ethernetMAC_hex-colon" "$temp1"
			temp1="\""$(getField "ethernetMAC" "hex-stripped" 0)"\""
			builddumpout "ethernetMAC_hex-stripped" "$temp1"
			temp1="\""$(getField "ethernetMAC" "hex" 0)"\""
			builddumpout "ethernetMAC_hex" "$temp1"		
		elif [[ "$field" = "sixBMAC" ]]; then
			temp="["$(getField "$field" "dec-comma" 0)"]"
			builddumpout "$field" "$temp"
			temp1="\""$(getField "sixBMAC" "hex-colon" 0)"\""
			builddumpout "sixBMAC_hex-colon" "$temp1"
			temp1="\""$(getField "sixBMAC" "hex-stripped" 0)"\""
			builddumpout "sixBMAC_hex-stripped" "$temp1"
			temp1="\""$(getField "sixBMAC" "hex" 0)"\""
			builddumpout "sixBMAC_hex" "$temp1"
		else
			temp="\""$(getField "$field" "ascii" 0)"\""
			builddumpout "$field" "$temp"
		fi
	done
	if [[ $jsonoutput -eq 1 ]]; then
		if [[ $ssl -eq 1 ]]; then
			sslout=$(eval "echo $ssltemplate")
			sslout2=$(eval "echo $ssltemplate2")
			dumpout="$dumpout,$sslout,$sslout2}"
		else
			dumpout="$dumpout}"
		fi
		echo "$dumpout"
	else
		echo -e "$dumpout"	
	fi
}



softstoragepath=""
softeedbname="eeprom.db"
database=""
platform=""
haveRealEEprom=1
platfromDetectAndSetup(){
	hasi2c=$(which i2cdump)
	wwrelaydetectstring="     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f\n00:          -- -- -- -- -- -- -- -- -- -- -- -- -- \n10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- \n20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- \n30: -- -- -- -- UU -- -- -- -- -- -- -- -- -- -- -- \n40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- \n50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- \n60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- \n70: -- -- -- -- -- -- -- --                              0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f\n00:          -- -- -- -- -- -- -- -- -- -- -- -- -- \n10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- \n20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- \n30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- \n40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- \n50: 50 51 52 53 54 55 56 57 -- -- -- -- -- -- -- -- \n60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- \n70: -- -- -- -- -- -- -- --                         "
	# wwrelaydetectstring="0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
	# 00:          -- -- -- -- -- -- -- -- -- -- -- -- -- 
	# 10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	# 20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	# 30: -- -- -- -- UU -- -- -- -- -- -- -- -- -- -- -- 
	# 40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	# 50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	# 60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	# 70: -- -- -- -- -- -- -- --                              0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
	# 00:          -- -- -- -- -- -- -- -- -- -- -- -- -- 
	# 10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	# 20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	# 30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	# 40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	# 50: 50 51 52 53 54 55 56 57 -- -- -- -- -- -- -- -- 
	# 60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	# 70: -- -- -- -- -- -- -- --                         "
	wwrelaydetectstring=$(echo -e "$wwrelaydetectstring") 
	if [[ $hasi2c != "" ]]; then
		out0=$(i2cdetect -y 0);
		out1=$(i2cdetect -y 1);
		sawWWdetectstring="$out0$out1"
		#i had to meld to figure out the difference... note for future
		# echo "'$sawWWdetectstring'" >o1
		# echo "'$wwrelaydetectstring'" >02
		# echo "'$sawWWdetectstring'"
		# echo "what I have saved: "
		# echo "'$wwrelaydetectstring'"
		if [[ "$wwrelaydetectstring" = "$sawWWdetectstring" ]]; then
			platform="WWRelay01"
			softstoragepath="/mnt/.boot/.ssl"
			mountDevice="/dev/mmcblk0p1"
			mountPoint="/mnt/.boot"
			mountFileStorage "$mountDevice" "$mountPoint" 
			createSoftStoragePath "$softstoragepath"
			iccpages["primary"]=0x50
			iccpages["cloudURL"]=0x51
			iccpages["devicejsURL"]=0x52
			iccpages["devicedbURL"]=0x53
		else
			platform="couldn't match a platform. check platform detection code."
			echo "$platform"
			exit
		fi
	else
		platform="softRelay"
		haveRealEEprom=0	
		softstoragepath="/userdata/.ssl"
		createSoftStoragePath "$softstoragepath"
		database="$softstoragepath/$softeedbname"
		database_create $database
		source "$database"
	fi
}

#---------------------------------------------------------------------------------------------------------------------------
# main and cli Processing
#---------------------------------------------------------------------------------------------------------------------------
prettyprintfields(){
	printf "  %-35s %-50s\n" "field:" "any field used in the eeprom or keystore database from the following list"
	for fielddescKey in "${!fields_description[@]}"; do
		c1="$fielddescKey:"
		c2="${fields_description[$fielddescKey]}"
		printf "       %-30s %-50s\n" "$c1" "$c2"
	done
}


getuseage(){
	echo -e "Useage: $0 get <help | field | all | some > where:"
	printf "  %-35s %-50s\n" "help:" "this help"
	printf "  %-35s %-50s\n" "all:" "dump everything to standard out (set -j flag for json)"
	printf "  %-35s %-50s\n" "some:" "dump all fields noted in a comma seperated list, eg. get some relayID,ssl_ca_ca to standard out (set -j flag for json)"

	prettyprintfields
	exit
}

setuseage(){
	echo -e "Useage: $0 set <help | field  | jsonfile.json> [<data for the field>] where:"
	printf "  %-35s %-50s\n" "help:" "this help"
	printf "  %-35s %-50s\n" "jsonfile.json:" "imports a json file and places into persistant storage"
	prettyprintfields
	exit
}

eraseuseage(){
	echo -e "Useage: $0 erase <help | field | eeprom | softstore | all> where:"
	printf "  %-35s %-50s\n" "help:" "this help"
	printf "  %-35s %-50s\n" "eeprom:" "erases everything in the eeprom or softeeprom if that exists"
	printf "  %-35s %-50s\n" "softstore:" "erases everything in the software eeprom and software directory"
	printf "  %-35s %-50s\n" "all:" "erases everything in eeprom and softstore"
	prettyprintfields
	exit
}

installuseage(){
	echo -e "Useage: $0 install help\nUseage:$0 install all <path-to-ssl-storage-dir> <file>\nUseage:$0install field <field> <file>\n"
	printf "  %-35s %-50s\n" "help:" "this help"
	printf "  %-35s %-50s\n" "all:" "places the ssl key files as .pem into directory and places all fields into a sh file or -j json file"
	printf "  %-35s %-50s\n" "field:" "places the field into a file as a .sh file or -j json file, or if the file is a ssl type, into a .pem automatically"
	prettyprintfields
	exit
}	

main(){
	log silly "'$maincommand' called.  '$1' '$2' '$3'"
	platfromDetectAndSetup
	if [[ $dumpallset -eq 1 ]]; then
		dumpall
	elif [[ $maincommand = "get" ]]; then
		if [[ "$1" = "-h" || "$1" = "--help" || "$1" = "help" || "$1" = "" ]]; then
			getuseage
		else
			getit "$1" "$2"
		fi
	elif [[ $maincommand = "set" ]]; then
		if [[ "$1" = "-h" || "$1" = "--help" || "$1" = "help" || "$1" = "" ]]; then
			setuseage
		else
			setit "$1" "$2"
		fi
	elif [[ $maincommand = "erase" ]]; then
		if [[ "$1" = "-h" || "$1" = "--help" || "$1" = "help" || "$1" = "" ]]; then
			eraseuseage
		else
			eraseit "$1"
		fi
	elif [[ $maincommand = "install" ]]; then
		if [[ "$1" = "-h" || "$1" = "--help" || "$1" = "help" || "$1" = "" || "$2" = "" || "$3" = "" ]]; then
			installuseage
		else
			installit "$1" "$2" "$3"
		fi
	else
		clihelp_displayHelp "main command must be $maincommandoptions"
	fi
}

jsonoutput=0
maincommandoptions="<[get|set|erase|install]>"
mainAutoMunge="<[production|development|fsg]>"
fieldtypes="<[ascii|decimal|hex|hex-stripped|hex-colon|dec-comma]>"
#shellcheck disable=SC2034

declare -A hp
hp[description]="EEPROM and ssl key store tool"
hp[useage]="-options $maincommandoptions <[fields|help]> [data]"
hp[aa]="automatically mundge in ca/intermediates and urls for $mainAutoMunge"
hp[d]="dump all eeprom data"
hp[h]="help"
hp[i]="dump all i2c pages used"
hp[j]="json output format"
hp[l]="no newline on gets standard output"
hp[mm]="munge data after (over) the import json data: Key=data,Key=data,Key=data e.g. ledConfig=01,hardwareVersion=0.1.1"
hp[nn]="munge data before (under) the import json data: Key=data,Key=data,Key=data e.g. ledConfig=01,hardwareVersion=0.1.1"
hp[oo]="during json import, mundge data <file.sh|file.json> will be applied after (over) the imported json file"
hp[tt]="sets the fieldtype for input data $fieldtypes"
hp[uu]="during json import, mundge data <file.sh|file.json> will be applied before (under) the imported json file"
hp[e5]="\t${BOLD}${UND}Set everthing from a json file ${NORM}\n\t\t$0 set file.json${NORM}\n"
hp[e4]="\t${BOLD}${UND}Set ethernetMAC using hex-colon format ${NORM}\n\t\t$0 -t hex:colon set ethernetMAC 00:a5:09:00:00:07 ${NORM}\n"
hp[e3]="\t${BOLD}${UND}Get radioConfig using hex output format ${NORM}\n\t\t$0 -t hex get relayID ${NORM}\n"
hp[e2]="\t${BOLD}${UND}Set ledConfig using hex-stripped fromat  ${NORM}\n\t\t$0 -t hex-stripped set relayID 5757524c303030304458${NORM}\n"
hp[e1]="\t${BOLD}${UND}Get the pairingcode ${NORM}\n\t\t$0 get pairingCode${NORM}\n"
hp[e6]="\t${BOLD}${UND}Dump all data to standard out in json format ${NORM}\n\t\t$0 -j get all${NORM}\n"
hp[e7]="\t${BOLD}${UND}Erase the ssl_ca_intermediate field ${NORM}\n\t\t$0 erase ssl_ca_intermediate${NORM}\n"
hp[e8]="\t${BOLD}${UND}Erase the relayID field ${NORM}\n\t\t$0 erase relayID${NORM}\n"
hp[e9]="\t${BOLD}${UND}Erase everything ${NORM}\n\t\t$0 erase all${NORM}\n"
hp[e10]="\t${BOLD}${UND}Erase the softstore ${NORM}\n\t\t$0 erase softstore${NORM}\n"
hp[e11]="\t${BOLD}${UND}Import json automatically add fsg missing ca,intermediate, command line mundge-over the ledConfig,firmwareVersion ${NORM}\n\t\t$0 -a fsg -m ledConfig=02,furnwareVersion=0.0.0 set 2017-01-19T18-37-25.214Z.json${NORM}\n"
hp[e12]="\t${BOLD}${UND}Import json munging over with a file ${NORM}\n\t\t$0 -a fsg -o file.json set import.json${NORM}\n"

argprocessor(){
	switch_conditions=$(clihelp_switchBuilder)
	while getopts "$switch_conditions" flag; do
		case $flag in
			a) automunge=$OPTARG; ;;
b) ;;
a) ;;
d) dumpallset=1; ;;
f) ;;
h) clihelp_displayHelp; ;;
i) i2cdumpit=1; ;;
j) jsonoutput=1; ;;
l) nonewline=1; ;;
o) mundgeOveridefile=$OPTARG; ;;
m) mundgeOvertext=$OPTARG; ;;
n) mundgeUndertext=$OPTARG; ;;
o) ;;
p) ;;
P) ;;
r) ;;
s) ;;
t) fieldtype=$OPTARG; ;;
T) ;;
u) mundgeUnderrideFile=$OPTARG; ;;
v) ;;
\?) echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed.";clihelp_displayHelp;exit; ;;
esac
done
shift $(( OPTIND - 1 ));
maincommand=$1
shift 1
main $@
}
#---------------------------------------------------------------------------------------------------------------------------
# Entry
#---------------------------------------------------------------------------------------------------------------------------

if [[ "$#" -lt 1 ]]; then
	clihelp_displayHelp
else
	argprocessor "$@"
fi




