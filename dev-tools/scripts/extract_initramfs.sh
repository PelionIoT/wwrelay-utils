#!/bin/bash
if [[ $1 = "--help" || $1 = "-h" || $1 = "" || $1 != *"initramfs.img" ]]; then
	echo "Useage: $0 <initramfs.img>"
fi
tempdir=$(mktemp -d)
dd if=$1 of=$tempdir/initramfs.igz bs=64 skip=1
cd $tempdir
cat $tempdir/initramfs.igz | gunzip | cpio -idmv
echo "your files are in $tempdir"
rm -rf $tempdir/initramfs.igz