#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------------
#  utils i2c
#-----------------------------------------------------------------------------------------------------------------------

#/	Desc:	erases the page called
#/	Ver:	.1
#/	$1:		page
#/	Out:	n/a
#/	Expl:	i2c_erasePage 0x50
i2c_erasePage(){
	local page="$1"
	local erasei
	for erasei in {0..255}; do 
		i2cset -y 1 $page $erasei 0xff b; 
	done
} #end_i2c_erasePage

#/	Desc:	erases one character with 0xFF
#/	Ver:	.1
#/	$1:		page
#/	$2:		posisition
#/	$3:		
#/	Out:	n/a
#/	Expl:	i2c_eraseOne 0x50 21
i2c_eraseOne(){
	local page="$1"
	local position="$2"
	i2cset -y 1 $page $position 0xff b; 
} #end_i2c_eraseOne

#/	Desc:	grabs one character from the Eerpom
#/	Ver:	.1
#/	$1:		page
#/	$2:		position
#/	Out:	outputs the character in native format
#/	Expl:	hex=(i2c_getOne 0x50 2)
i2c_getOne(){
	local page="$1"
	local position="$2"
	log silly "i2cget -y 1 $page $position b"
		a=$(i2cget -y 1 $page $position b) 
	echo $a
} #end_i2c_getOne

#/	Desc:	sets one character via the i2cset command
#/	Ver:	.1
#/	$1:		page
#/	$2:		position
#/	$3:		hexvalue
#/	Out:	n/a
#/	Expl:	i2c_setOne 0x50 20 0x33
i2c_setOne(){
	local page="$1"
	local position="$2"
	local hexvalue="$3"
	log silly "i2cset -y 1 $page $position $hexvalue"
		a=$(i2cset -y 1 $page $position $hexvalue)
	#echo $a
} #end_i2c_setOne