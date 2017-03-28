#!/bin/bash
#a tool that can build a bootable version of the factory partition
if [[ ! -e $1 ]]; then
	echo "Useage: $0 <device>"
	echo "-e.g. $0 /dev/sda"
else
	umount "$1"
	echo -e "o\nn\np\n1\n4096\n106495\nn\np\n2\n106496\n3178495\nn\np\n3\n3178496\n3383295\nn\ne\n3383296\n3792895\nn\n\n3590143\nn\n\n\nt\n1\nc\na\n1\nw\n" | fdisk "$1"
	if [[ $? -ne 0 ]]; then
		echo "not equal zero after fdisk"
	fi
	sleep 10
	partprobe "$1"
		if [[ $? -ne 0 ]]; then
		echo "not equal zero after partprobe"
	fi
	sleep 10
	sync
	mkfs.vfat "$1"1
	fdisk -l "$1"
	mkfs.ext4 "$1"2
	mkfs.ext4 "$1"3
	mkfs.ext4 "$1"5
	mkfs.ext4 "$1"6
	mkdir p{1,2,3,5,6}
	mount "$1"1 p1
	mount "$1"2 p2
	mount "$1"5 p5
	#cat boot.tar.xz | tar -xJ -C p1
	#cat factory.tar.xz | tar -xJ -C p2
	cp -r /mnt/.overlay/factory/ p2
	cp -r /mnt/.boot/ p1
	rm -rf p2/etc/init.d/wwrelay
	cp wwrelay p2/etc/init.d/
	chmod 755 p2/etc/init.d/wwrelay
	cp wwupdate.sh p1/
	mv p1/sun7i-a20-wigwagrelayv4.dtb p1/Xsun7i-a20-wigwagrelayv4.dtb
	chmod 777 p1/wwupdate.sh
	mkdir p5/slash
	mkdir p5/work
	# umount "$1"1
	# umount "$1"2
	# umount "$1"5
fi



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
l) ;;
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
