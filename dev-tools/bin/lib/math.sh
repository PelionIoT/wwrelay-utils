#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------
# math utils
#---------------------------------------------------------------------------------------------------------------------------

#/	Desc:	Takes an integer and oupts hex
#/	Ver:	.1
#/	$1:		decimal
#/	$2:		name1
#/	$3:		name1
#/	Out:	hex string 2 digit format
#/	Expl:	out=$(math_dec2hex 33)
math_dec2hex() {
	capture=$(echo "obase=16;ibase=10; $1" | bc)
	lencapture=${#capture}
	if [[ $lencapture -eq 1 ]]; then
		echo "0$capture"
	else
		echo "$capture"
	fi
} #end_math_dec2hex

#/	Desc:	Takes an hex and oupts integer
#/	Ver:	.1
#/	$1:		hex
#/	Out:	dec string
#/	Expl:	out=$(math_hex2dec 0x22)
math_hex2dec() {
	printf "%d\n" $1
} #end_math_hex2dec

#/	Desc:	converts hex 2 ascii
#/	Ver:	.1
#/	$1:		hex
#/	Out:	ascii
#/	Expl:	$out=(math_hex2ascii "0x20")
math_hex2ascii() {
	a=$(echo "$1" | sed s/0/\\\\/1)
	echo -en "$a"
	#echo $b
} #end_math_hex2ascii

#/	Desc:	converts a single ascii character to hex
#/	Ver:	.1
#/	$1:		ascii char
#/	Out:	hex
#/	Expl:	output=$(math_ascii2hex "a")
math_ascii2hex(){
	letterhex=$(echo "$1" | od -t x1 | xargs | awk '{print $2}')
	echo -en "$letterhex"
} #end_math_ascii2hex
