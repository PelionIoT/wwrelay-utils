#!/bin/bash
#Place this file onto a USB drive and boot with it to control the initloader options
# or
#Rename this file to upgrade.sh and place in the /upgrades folder on the relay and reboot
# or
#Use the button to enter each mode, the corresponding colors are available below above the function


runit(){
	#valid Functions Uncomment one
	#Reboots the system, if you leave this usb in, you will simply be in reboot loop
    #durning the button function on wigwag hardware this is color: green
    #rebootit
    
    #wipes the user parttion and and the userdatabase paritition taking it back to a factory & upgrade partition only
    #this means it will behave as a relay would from the factory, with the upgrade paritition in place
    #durning the button function on wigwag hardware this is color: orange
    #wipeuser
    
    #wipes the user partition, userdatabase partition and upgrade partition, taking the user back to factory
    #this means the relay wiill behave exactly as it did from the factory, with just the factory partition
    #durning the button function on wigwag hardware this is color: magenta
    #factoryit
    
    #installs the latest version of firmware in the most normal way.  Same as running a upgrade x.x.xxxx
    #durning the button function on wigwag hardware this is color: pink
    #cloudlatest

    #restores the relay to a factory state, but uses the cloud to get the absolute latest cloud firmware
    #the device can handle.  it does replace the factory paortition.
    #durning the button function on wigwag hardware this is color: cyan
    #cloudfactory
    
    #does a 7 pass DOD-wipe DoD 5220.22-M standard
    #this is a dangerous option and is not available via the button....
    #DOD7     
    
    #boots to a busybox shell.  Good for development of the initloader and other stuff
    #durring the button function on wigwag hardware is color: blue
    #shell                                                                                                                                                                                                                                                                                                                                                                                                                                                
}

runit
