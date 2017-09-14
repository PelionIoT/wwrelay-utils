package main

import "log"
import "fmt"
import I2C "golang.org/x/exp/io/i2c"
import "regexp"

func check(err error) {
    if err != nil { 
        log.Fatal(err) 
    }
}

type eelayout struct {
    name string
    pageaddr int
    memaddr byte
    length int
    format string
    regex string
} 

type eeData struct {
    name string
    format string
    data []byte
}

var metadata = []eelayout {
    eelayout {"BRAND",            0x50, 0, 2, "string", ""}, 
    eelayout {"DEVICE",           0x50, 2, 2, "string", ""},
    eelayout {"UUID",             0x50, 4, 6, "string", ""}, 
    eelayout {"hardwareVersion",  0x50, 10, 5, "string", ""}, 
    eelayout {"firmwareVersion",  0x50, 15, 5, "string", ""}, 
    eelayout {"radioConfig",      0x50, 20, 2, "string", ""}, 
    eelayout {"year",             0x50, 22, 1, "string", ""}, 
    eelayout {"month",            0x50, 23, 1, "string", ""}, 
    eelayout {"batch",            0x50, 24, 1, "string", ""}, 
    eelayout {"ethernetMAC",      0x50, 25, 6, "byte", ""}, 
    eelayout {"sixBMAC",          0x50, 31, 8, "byte", ""}, 
    eelayout {"relaySecret",      0x50, 39, 32, "string", ""}, 
    eelayout {"pairingCode",      0x50, 71, 25, "string", ""}, 
    eelayout {"ledConfig",        0x50, 96, 2, "string", ""}, 
    eelayout {"cloudURL",         0x51, 0, 100, "string", "[^a-zA-Z0-9.:/-]"}, 
    eelayout {"devicejsCloudURL", 0x52, 0, 100, "string", "[^a-zA-Z0-9.:/-]"}, 
    eelayout {"devicedbCloudURL", 0x53, 0, 100, "string", "[^a-zA-Z0-9.:/-]"},
}

func get_eeprom(prop eelayout) eeData {

    bus, err := I2C.Open(&I2C.Devfs{Dev: "/dev/i2c-1"}, prop.pageaddr)          
    if err != nil {                                                             
        check(err)                                               
    }

    data := make([]byte, prop.length)

    e := bus.ReadReg(prop.memaddr, data)
    if e != nil {                    
        check(e)                 
    }

    if len(prop.regex) > 0 {
        r, _ := regexp.Compile(prop.regex)
        dataStr := r.ReplaceAllString(string(data), "")
        data = []byte(dataStr)
    }

    // if prop.format == "string" {
    //     fmt.Printf("%s --> %s\n", prop.name, data)
    // } else if prop.format == "byte" {
    //     fmt.Printf("%s --> %# x\n", prop.name, data)            
    // }

    bus.Close()

    return eeData{prop.name, prop.format, data}
}
             
func main() {
    eepromData := make([]eeData, len(metadata))

    for i := 0; i < len(metadata); i++ {  
        eepromData[i] = get_eeprom(metadata[i])  

        if eepromData[i].format == "string" {
            fmt.Printf("%s --> %s\n", eepromData[i].name, eepromData[i].data)
        } else if eepromData[i].format == "byte" {
            fmt.Printf("%s --> %# x\n", eepromData[i].name, eepromData[i].data)            
        }
    }
}  
