#!/bin/bash

device="$1"
fname="$2"
size="$3"

bon=$(which bonnie++)
if [[ $bon = "" ]]; then 
	echo "Install bonnie++"
	echo "sudo apt-get install bonnie++"
	exit
fi

wami=$(whoami)
if [[ $wami != "root" ]]; then
	echo "You must be root"
	exit
fi


USEAGE(){
	echo "USEAGE: $0 <hd dev> <filename (no space)> <size in GB (just number)>"
	echo "note on size.  It should be 2x the size of your ram.  So for 2GB Ram, put 4"
	exit
}

if [[ "$device" = "" || $1 = "-h" || $1 = "--help" || "$fname" = "" || "$size" = "" ]]; then 
	USEAGE
fi


temp=$(mktemp -d)
mount "$device" $temp
speed=$(lsusb -t | grep Mass | awk '{print $11}')
echo "Your usb is connected at: $speed"
cmd="bonnie++ -d $temp -s $size"G" -n 0 -m $fname -f -b -u root:root"
echo "$cmd"
ou=$(eval "$cmd" | tail -1 | bon_csv2html > $fname.html)
umount $1 >> /dev/null
umount $temp >> /dev/null
echo "looking for: $fname.html"
ls -al
