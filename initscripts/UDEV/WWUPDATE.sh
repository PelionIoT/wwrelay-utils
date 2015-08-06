#!/bin/bash

mountdir="/run/media/WWUPDATE"
disk="/dev/WWUPDATEp1"
initscript="init.sh"
logfile="/wigwag/log/update.log"


#mounts the usb key
function mounter() {
	echo "mounting media $disk ">> $logfile
	mkdir -p $mountdir
	mount $disk $mountdir
}

#unoumnts the usb key
function umounter() {
	echo "unmounting media $disk ">> $logfile
	umount $mountdir 
	umount $disk 
}

#runs an init.sh script from the usb key
function runinit() {
cd $mountdir
if [[ -e $initscript ]]; then
	. $initscript
	main
fi
}

#deviceJS Update code
function updater() {
	date > /tmp/newdatetest
#jordan your code here....
#x
#y
#z
}






pushd .
mounter
runinit
updater
popd
umounter