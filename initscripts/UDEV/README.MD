UPGRADE CAPABILITY
===========================
Using UDEV we can launch a script to do just about anything on a Relay.  This includes upgrading major protions of the disk.

#OFFICIAL USB UPGRADE INSTRUCTIONS FOR AN END USER
3 step process:
* Follow instructions on how to Format an upgrade USB Key
* Follow instructions on how to Install an upgrade image onto the USB key
* Insert the USB key into the Relay
##Formatting an upgrade USB Key
* Format your USB Key using FAT32.
 * thats it.  No more need to rename the disk

##INSTALL AN UPGRADE IMAGE ONTO THE USB KEY
@jordan

##INSERTING the USB KEY
* Insert the USB Key into a running relay

#DEVELOPERS
Upon insertion of the USB Key properly named as described above, the following occurs

* Udev Rule 96 detects any USB Key named anything 
* Udeve Rule 96 launches the script **/wigwag/wwrelay-utils/initscripts/UDEV/WWUPDATE.sh**
* **WWUDATE.sh** does the following
 * mounts the USB Partion WWUPDATEp1 to /run/media/WWUDATE
 * runs the script /run/media/WWUPDATE/wwupdate.sh
 * unmounts the USB key

##EXAMPLE

SPECIAL wwupdate.sh SCRIPT
When you insert a USB key (formated as in the instructions above) you can include a special script named **wwupdate.sh** , that will be executed upon insertion into the relay.   **wwupdate.sh** should have executable permissions.  

###GRAB IP
```js
#!/bin/bash

function dosomethingcool() {
ifconfig > ifconfig.txt
}

dosomethingcool
```

###CLIENT

###UDEV

