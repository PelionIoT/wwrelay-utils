#!/bin/bash
tempdir=$(mktemp -d)
dd if=$1 of=$tempdir/initramfs.igz bs=64 skip=1
cat $tempdir/initramfs.igz | gunzip | cpio -idmv
rm -rf $tempdir/initramfs.igz