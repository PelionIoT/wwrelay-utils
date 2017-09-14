package main

import "log"
import "fmt"
import I2C "golang.org/x/exp/io/i2c"
import "regexp"
import "encoding/hex"

func check(err error) {
    if err != nil { 
        log.Fatal(err) 
    }
}

type eeprom_anatomy struct {
    name string
    pageaddr int
    memaddr byte
    length int
} 

type eeData struct {
    name string
    data string
}

var metadata = []eeprom_anatomy {
    eeprom_anatomy {"ARCH_BRAND",             0x50, 0, 2   }, 
    eeprom_anatomy {"ARCH_DEVICE",            0x50, 2, 2   },
    eeprom_anatomy {"ARCH_UUID",              0x50, 4, 6   }, 
    eeprom_anatomy {"ARCH_RELAYID",           0x50, 0, 10  }, 
    eeprom_anatomy {"ARCH_HARDWARE_VERSION",  0x50, 10, 5  }, 
    eeprom_anatomy {"ARCH_WW_PLATFORM",       0x50, 10, 5  }, 
    eeprom_anatomy {"ARCH_FIRMWARE_VERSION",  0x50, 15, 5  }, 
    eeprom_anatomy {"ARCH_RADIO_CONFIG",      0x50, 20, 2  }, 
    eeprom_anatomy {"ARCH_YEAR",              0x50, 22, 1  }, 
    eeprom_anatomy {"ARCH_MONTH",             0x50, 23, 1  }, 
    eeprom_anatomy {"ARCH_BATCH",             0x50, 24, 1  }, 
    eeprom_anatomy {"ARCH_ETHERNET_MAC",      0x50, 25, 6  },
    eeprom_anatomy {"ARCH_SIXLBR_MAC",        0x50, 31, 8  },
    eeprom_anatomy {"ARCH_RELAY_SECRET",      0x50, 39, 32 }, 
    eeprom_anatomy {"ARCH_PAIRING_CODE",      0x50, 71, 25 }, 
    eeprom_anatomy {"ARCH_LED_CONFIG",        0x50, 96, 2  }, 
    eeprom_anatomy {"ARCH_LED_COLOR_PROFILE", 0x50, 96, 2  }, 
    eeprom_anatomy {"ARCH_CLOUD_URL",         0x51, 0, 250 }, 
    eeprom_anatomy {"ARCH_CLOUD_DEVJS_URL",   0x52, 0, 250 }, 
    eeprom_anatomy {"ARCH_CLOUD_DDB_URL",     0x53, 0, 250 },
}

var regex = "[^a-zA-Z0-9.:/-]"

func get_eeprom(prop eeprom_anatomy) eeData {

    bus, err := I2C.Open(&I2C.Devfs{Dev: "/dev/i2c-1"}, prop.pageaddr)          
    if err != nil {                                                             
        check(err)                                               
    }

    data := make([]byte, prop.length)

    e := bus.ReadReg(prop.memaddr, data)
    if e != nil {                    
        check(e)                 
    }

    dataStr := string(data)

    r, _ := regexp.Compile(regex)
    dataStr = r.ReplaceAllString(string(data), "")

    if prop.name == "ARCH_WW_PLATFORM" {
        dataStr = "wwrelay_v" + dataStr
    }

    if prop.name == "ARCH_ETHERNET_MAC" || prop.name == "ARCH_SIXLBR_MAC" {
        dataStr = hex.EncodeToString(data)
    }

    if prop.name == "ARCH_LED_COLOR_PROFILE" {
        if dataStr == "02" {
            dataStr = "RBG"
        } else {
            dataStr = "RGB"
        }
    }

    bus.Close()

    return eeData{prop.name, dataStr}
}
             
func main() {
    eepromData := make([]eeData, len(metadata))

    for i := 0; i < len(metadata); i++ {  
        eepromData[i] = get_eeprom(metadata[i])  

        fmt.Printf("%s --> %s\n", eepromData[i].name, eepromData[i].data)
    }
}  
