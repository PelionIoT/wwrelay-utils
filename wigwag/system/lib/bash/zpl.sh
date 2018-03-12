#!/bin/bash
zstart="^XA"
zend="^XZ"
printstring=""

zpl_sendToPrinter(){
	echo "$printstring" | timeout 1 nc $1 $2
}

zpl_getRotation(){
	Rotation=$1
	if [[ "$Rotation" = "90" ]]; then
		rotate="R"
	elif [[ "$Rotation" = "180" ]]; then
		rotate="I"
	elif [[ "$Rotation" = "270" ]]; then
		rotate="B"
	else
		rotate="N";
	fi
	echo "$rotate"
}


_p(){
	printstring="$printstring$1"
}

zpl_start(){
	_p "^XA"
}

zpl_unicode(){
	_p "^CI28"
}

zpl_end(){
	_p "^XZ"
}

#       X
#       ------------------>
#     Y |
#       |
#       |
#       |
#       |
#       |
zpl_goto(){
	x=$1
	y=$2
	_p "^FO$1,$2"
}

#/	Desc:	generates a qr code
#/	Ver:	.1
#/	$1:		Rotation <0|90|180|270>
#/	$2:		zoom <0-9>
#/	$3:		Data <data>
#/	Out:	
#/	Expl:	qrcode 90 4 "i am qrcode data"
zpl_qrcode(){
	Rotation=$(zpl_getRotation $1)
	zoom=$2
	DATA=$4
	model=2
	quality=$3

	#https://developer.zebra.com/thread/34767


	_p "^BQ$Rotation,$model,$zoom,$quality^FH^FD"$quality"A,$DATA^FS"
#_p "^BQN,2,4^FH^FDHM,A^FH^FDU+00A1 in UTF8 = _C2_A1^FS"
}

zpl_print(){
	TEXT="$1"
	_p "^FD$TEXT^FS"
}


zpl_fontset(){
	case $1 in
		A) h=9;w=5; ;;
		#
		B) h=11;w=7; ;;
		#
		C) h=18;w=10; ;;
		#
		D) h=18;w=10; ;;
		#
		E) h=28;w=15; ;;
		#
		F) h=26;w=13; ;;
		#
		G) h=60;w=40; ;;
		#
		H) h=21;w=13; ;;
		#
		GS) h=24;w=24; ;;
		#
		O) h=18;w=12; ;;
		#
	esac
	magnification=$2;
	if [[ $magnification = "" ]]; then
		magnification=1;
	fi
	_p "^CF$1,$(($h * magnification)),$(($w * magnification))"
}
zpl_font(){
	Rotation=$(zpl_getRotation $1)
	LetterHeight=$2
	LetterWidth=$3
	_p "^CFA$Rotation,$LetterHeight,$LetterWidth"
}

zpl_row(){
	Rid=$1
	startRow=$2
	if [[ $Rid = "" ]]; then
		Rid=0
	fi
	if [[ $startRow != "" ]]; then
		TR=$startRow
	elif [[ $topRow != "" ]]; then
		TR=$topRow
	else
		TR=0;
	fi
	if [[ $rowHeight = "" ]]; then
		rH=50;
	else
		rH=$rowHeight
	fi
	echo "$TR + ( $rH * $Rid )" | bc
}


zpl_printRowStream(){
	font="$1"
	mag="$2"
	sc="$3"
	sr="$4"
	shift
	shift
	shift
	shift
	rowinc=0;
	while (( "$#" )); do
		goto $sc $(row $rowinc $sr)
		rowinc=$(($rowinc + 1))
		fontset $font $mag
		print "$1"
		shift
	done
}





