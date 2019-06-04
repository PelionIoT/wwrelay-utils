#!/bin/bash

# Copyright (c) 2018, Arm Limited and affiliates.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

pushd . >> /dev/null
MMCDEV="$1"
if [[ "$MMCDEV" = "" || "$2" = "" ]]; then
	echo -e "\tUSEAGE:\t$0 <device to burn> <image.tar.gz | path_to_folder_holding_image.tar.gz>"
	echo -e "\t\t$0 /dev/mmcblk1 ./path/to/tar.gz"
	exit 99
fi


error=0
if [[ $2 != *"tar.gz" ]]; then
	cd $2
	fImage=`ls *-field-*update.tar.gz`
	rImage=`ls RelayBuild-*.img.tar.gz`
	if [[ $fImage != "" ]]; then
		Image=$fImage
		ddtype=0
	else
		ddtype=1
		Image=$rImage
	fi
else
	Image=$2
fi

ImageFile=$(basename $Image)
ImageDir=$(dirname $Image)

echo "my Image: $Image"
echo "my Filename: $ImageFile"
echo "my Image dir: $ImageDir"
echo "my MMCDEV: $MMCDEV"
cd $ImageDir
pwd
OLDRAM="u-boot.bin"
NEWRAM="u-boot_1500V_384MHZ_0EMR_124ZQ_nODT_nDT.bin"
RAM="$NEWRAM"

echo "started the emmcwriter" > /wigwag/log/emmcWritersh.log

function logg(){
	dodebug=1
	if [[ $dodebug -eq 1 ]]; then
		echo "$1"
		echo "$1" >> /wigwag/log/emmcWritersh.log
	fi
}


#---------------------------------------------------------------------------------------------------------------------------
# PARTITION DATA: SET THESES
#---------------------------------------------------------------------------------------------------------------------------
# this was the orignial factory version that went out in 1.0.1 - 1.1.65
BOOT_MiB="20"
FACTORY_MiB="1200"
UPGRADE_MiB="1000"
EXTENDED_PROTECTED_MiB="1510"
USER_MiB="1000"
USERDATA_MiB="500"
PROTECTED="4096"

# this is where we went to ..
BOOT_MiB="50"
FACTORY_MiB="2500"
UPGRADE_MiB="2000"
EXTENDED_PROTECTED_MiB="2010"
USER_MiB="1000"
USERDATA_MiB="1000"
PROTECTED="4096"

#---------------------------------------------------------------------------------------------------------------------------
# AND GET THESE OUT...
# #http://www.dr-lex.be/info-stuff/bytecalc.html
#---------------------------------------------------------------------------------------------------------------------------
BOOT_KiB="$(($BOOT_MiB*1024))"
FACTORY_KiB="$(($FACTORY_MiB*1024))"
UPGRADE_KiB="$(($UPGRADE_MiB*1024))"
EXTENDED_PROTECTED_KiB="$(($EXTENDED_PROTECTED_MiB*1024))"
USER_KiB="$(($USER_MiB*1024))"
USERDATA_KiB="$(($USERDATA_MiB*1024))"
BOOT_SECTORS="$(($BOOT_MiB*1024*2))"
FACTORY_SECTORS="$(($FACTORY_MiB*1024*2))"
UPGRADE_SECTORS="$(($UPGRADE_MiB*1024*2))"
EXTENDED_PROTECTED_SECTORS="$(($EXTENDED_PROTECTED_MiB*1024*2))"
USER_SECTORS="$(($USER_MiB*1024*2))"
USERDATA_SECTORS="$(($USERDATA_MiB*1024*2))"
BOOTs="$PROTECTED"
BOOTe="$(( $BOOTs + $BOOT_SECTORS-1 ))"
BOOTt="c"
FACTORYs="$((BOOTe+1))"
FACTORYe="$(($FACTORYs + FACTORY_SECTORS-1))"
FACTORYt="83"
UPGRADEs="$((FACTORYe+1))"
UPGRADEe="$(($UPGRADEs+$UPGRADE_SECTORS-1))"
UPGRADEt="83"
EXTENDEDs="$((UPGRADEe+1))"
EXTENDEDe="$(($EXTENDEDs+$EXTENDED_PROTECTED_SECTORS-1))"
EXTENDEDt="f"
USERs="$(($EXTENDEDs+2048))"
USERe="$(($USERs+$USER_SECTORS-1))"
USERt="83"
USERDATAs="$(($USERe+2048+1))"
USERDATAe="$(($USERDATAs+$USERDATA_SECTORS-1))"
USERDATAt="83"
OVERALL_SECTORS=$EXTENDEDe
OVERALL_KiB=$(($OVERALL_SECTORS / 2))
OVERALL_MiB=$(($OVERALL_KiB / 1024 ))
#OVERALL_KiB="$(((((($USERDATAe+1))/2))+16384))"
OVERALL_BS="$(($OVERALL_KiB*1024))"
SDIMG_SIZE="$((expr ${BOOT_SPACE_ALIGNED} + ${ROOT_PART_SIZE} + ${READONLY_SIZE} + ${USER_DATA_PART_SIZE} + ${CUSTOM_SIZE} + 16384))"
PART1="$BOOTs"
PART2="$FACTORYs"
PART3="$UPGRADEs"
PART5="$USERs"
PART6="$USERDATAs"


displayPartitioning(){
	logg "BOOTs $BOOTs"
	logg "BOOTe $BOOTe"
	logg "FACTORY $FACTORYs"
	logg "FACTORY $FACTORYe"
	logg "UPGRADEs $UPGRADEs"
	logg "UPGRADEe $UPGRADEe "
	logg "EXTENDEDs $EXTENDEDs"
	logg "EXTENDEDe $EXTENDEDe"
	logg "USERs $USERs"
	logg "USERe $USERe"
	logg "USERDATAs $USERDATAs"
	logg "USERDATAe $USERDATAe"
	logg "OVERALL_MiB" "$OVERALL_MiB"
	logg "OVERALL_KiB" "$OVERALL_KiB"
	logg "OVERALL_BS" "$OVERALL_BS"
	logg "PART1 $PART1"
	logg "PART2 $PART2"
	logg "PART3 $PART3"
	logg "PART5 $PART5"
	logg "PART6 $PART6"
}




makePartitions(){
	TARGET=$1
	BOOTx="o\nn\np\n1\n$BOOTs\n$BOOTe\n"
	FACTORYx="n\np\n2\n$FACTORYs\n$FACTORYe\n"
	UPGRADEx="n\np\n3\n$UPGRADEs\n$UPGRADEe\n"
	EXTENDEDx="n\ne\n$EXTENDEDs\n$EXTENDEDe\n"
	USERx="n\n$USERs\n$USERe\n"
	USERDATAx="n\n$USERDATAs\n$USERDATAe\n"
	BOOTy="t\n1\n$BOOTt\n"
	FACTORYy="t\n2\n$FACTORYt\n"
	UPGRADEy="t\n3\n$UPGRADEt\n"
	EXTENDEDy="t\n4\n$EXTENDEDt\n"
	USERy="t\n5\n$USERt\n"
	USERDATAy="t\n6\n$USERDATAt\n"
	BOOTz="a\n1\nw\n"

	
	# echo BOOTx: "echo -e \"$BOOTx\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# echo -e "$BOOTx" | sudo fdisk $TARGET; fdisk -l $TARGET
	# echo FACTORYx: "echo -e \"$FACTORYx\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# echo -e "$FACTORYx" | sudo fdisk $TARGET; fdisk -l $TARGET
	# echo UPGRADEx: "echo -e \"$UPGRADEx\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# echo -e "$UPGRADEx" | sudo fdisk $TARGET; fdisk -l $TARGET
	# echo EXTENDEDx: "echo -e \"$EXTENDEDx\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# echo -e "$EXTENDEDx" | sudo fdisk $TARGET; fdisk -l $TARGET
	# echo USERx: "echo -e \"$USERx\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# echo -e "$USERx" | sudo fdisk $TARGET; fdisk -l $TARGET
	# echo USERDATAx: "echo -e \"$USERDATAx\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# echo -e "$USERDATAx" | sudo fdisk $TARGET; fdisk -l $TARGET
	# echo BOOTy: "echo -e \"$BOOTy\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# echo -e "$BOOTy" | sudo fdisk $TARGET; fdisk -l $TARGET
	# echo FACTORYy: "echo -e \"$FACTORYy\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# echo -e "$FACTORYy" | sudo fdisk $TARGET; fdisk -l $TARGET
	# echo UPGRADEy: "echo -e \"$UPGRADEy\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# echo -e "$UPGRADEy" | sudo fdisk $TARGET; fdisk -l $TARGET
	# #echo EXTENDEDy: "echo -e \"$EXTENDEDy\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# #echo -e "$EXTENDEDy" | sudo fdisk $TARGET; fdisk -l $TARGET
	# echo USERy: "echo -e \"$USERy\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# echo -e "$USERy" | sudo fdisk $TARGET; fdisk -l $TARGET
	# echo USERDATAy: "echo -e \"$USERDATAy\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# echo -e "$USERDATAy" | sudo fdisk $TARGET; fdisk -l $TARGET
	# echo DONE: "echo -e \"$DONE\" | sudo fdisk $TARGET; fdisk -l $TARGET"
	# echo -e "$DONE" | sudo fdisk $TARGET; fdisk -l $TARGET
	


	cmd="$BOOTx$FACTORYx$UPGRADEx$EXTENDEDx$USERx$USERDATAx$BOOTy$FACTORYy$UPGRADEy$USERy$USERDATAy$BOOTz"
	logg "$cmd"
	echo -e "$cmd" | sudo fdisk $TARGET
}

formatPartitions(){
	target=$1
	if [[ $target = "/dev/sd"* ]]; then
		pad="";
	else
		pad="p";
	fi
	mkfs.vfat -n "boot" -S 512 $target$pad"1"
	mkfs.ext4 -F -i 4096 -L "factory" $target$pad"2"
	mkfs.ext4 -F -i 4096 -L "upgrade" $target$pad"3"
	mkfs.ext4 -F -i 4096 -L "userdata" $target$pad"5"
	mkfs.ext4 -F -i 4096 -L "userdata" $target$pad"6"
}

mountPartitions(){
	target=$1
	mp=$2	
	if [[ $target = "/dev/sd*" ]]; then
		pad="";
	else
		pad="p";
	fi
	mkdir -p $mp/{1,2,3,5,6}
	mount $target$pad"1" $mp/1
	mount $target$pad"2" $mp/2
	mount $target$pad"3" $mp/3
	mount $target$pad"5" $mp/5
	mount $target$pad"6" $mp/6
}

umountPartitions(){
	mp=$1
	umount $mp/1
	umount $mp/2
	umount $mp/3
	umount $mp/5
	umount $mp/6
}

fillPartitions(){
	mntroot=$1
	if [[ ! -e factory.tar.xz ]]; then
		logg "tar -xf $Image -C ."
		tar --warning=no-timestamp -xf $Image -C .
		pushd . >> /dev/null
		logg "tar --warning=no-timestamp -xf upgrade.tar.gz -C ."
		tar --warning=no-timestamp -xf upgrade.tar.gz -C .
		ls -al
	fi
	logg "tar --warning=no-timestamp -xf boot.tar.xz -C $mntroot/1/"
	tar --warning=no-timestamp -xf boot.tar.xz -C $mntroot/1/
	logg "tar --warning=no-timestamp -xf factory.tar.xz -C $mntroot/2/"
	tar --warning=no-timestamp -xf factory.tar.xz -C $mntroot/2/
	logg "tar --warning=no-timestamp -xf upgrade.tar.xz -C $mntroot/3/"
	tar --warning=no-timestamp -xf upgrade.tar.xz -C $mntroot/3/
	logg "tar --warning=no-timestamp -xf user.tar.xz -C $mntroot/5/"
	tar --warning=no-timestamp -xf user.tar.xz -C $mntroot/5/
	logg "tar --warning=no-timestamp -xf userdata.tar.xz -C $mntroot/6/"
	tar --warning=no-timestamp -xf userdata.tar.xz -C $mntroot/6/
	popd >> /dev/null
}


ddUBOOT(){
	target=$1
	logg "	dd if=$RAM of=$target seek=8 bs=1024 > /dev/null 2>&1"
	dd if=$RAM of=$target seek=8 bs=1024 > /wigwag/log/emmcWritersh.log 2>&1
	if [[ ! $? -eq 0 ]]; then
		error=3
	fi
}


# dodd(){
# 	logg "entering the dd command"
# 	logg "tar xzOf $Image | sudo dd of=$MMCDEV bs=1MB"
# 	tar xzOf $Image | sudo dd of=$MMCDEV bs=1MB > /dev/null 2>&1
# 	if [[ ! $? -eq 0 ]]; then
# 		error=2
# 	fi
# 	if [[ $error -eq 0 ]]; then
# 		ddUBOOT $MMCDEV
# 	fi
# }


docheck(){
	logg "doing the check"
	blockdev --rereadpt $MMCDEV
	checkfileray[1]="/mnt/.p1/initramfs.img"
	checkfileray[2]="/mnt/.p2/wigwag/devicejs-ng/build.sh"
	checkfileray[3]="/mnt/.p3/lost+found"
	checkfileray[5]="/mnt/.p5/lost+found"
	checkfileray[6]="/mnt/.p6/etc/devicejs/db"
	for check in 1 2 3 5 6
	do
		if [[ $error -eq 0 ]]; then
			if [[ ! -e /mnt/.p$check ]]; then
				mkdir /mnt/.p$check
			fi
			mnt_dev=$MMCDEV"p$check"
			mount $mnt_dev /mnt/.p$check
			if [[ ! $? -eq 0 ]]; then
				error=1$check
			fi
			if [[ $error -eq 0 ]]; then
				temp=${checkfileray[$check]}
				thefile=$temp
				if [[ ! -e $thefile ]]; then
					error=2$check
				fi
			fi
		fi
	done
	for check in 1 2 3 5 6
	do
		mnt_dev=$MMCDEV"p$check"
		umount $mnt_dev > /dev/null 2>&1
	done
}

tmnt="/tmp/mnt"
# if [[ $DO_THE_DD_COMMAND_BECAUSE_WE_ARE_PRODUCTION -eq 1 ]]; then
# 	if [[ $ddtype -eq 1 ]]; then
# 		dodd
# 	else
logg "making some partitions"
#displayPartitioning
makePartitions $MMCDEV
formatPartitions $MMCDEV
fdisk -l $MMCDEV
mountPartitions $MMCDEV $tmnt
fillPartitions $tmnt
umountPartitions $tmnt
ddUBOOT $MMCDEV
docheck
exit $error
popd >> /dev/null