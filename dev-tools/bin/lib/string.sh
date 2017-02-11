#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------
# string libary utils
#---------------------------------------------------------------------------------------------------------------------------

#/	Desc:	removes all newlines from a string
#/	Ver:	.1
#/	$1:		string
#/	Out:	string
#/	Expl:	out=$(string_removeAllNewlines string)
string_removeAllNewlines(){
	echo "${1//'\n'/}" 
} #end_string_removeAllNewlines

#/	Desc:	replaces first instance of string with a string
#/	Ver:	.1
#/	$1:		full string
#/	$2:		search string
#/	$3:		replacement string
#/	Out:	full string
#/	Expl:	$out=$(string_replaceFirst fullstring search replace)
string_replaceFirst(){
	local "instr"="$1"
	local "searchfor"="$2"
	local "replacewith"="$3"
	echo ${instr/$searchfor/$replacewith}
} #end_string_replaceFirst

#/	Desc:	replaces all mattching strings with repacement string within string
#/	Ver:	.1
#/	$1:		full string
#/	$2:		search string
#/	$3:		replacement string
#/	Out:	full string
#/	Expl:	$out=$(string_replaceFirst fullstring search replace)
string_replaceAll(){
	local "instr"="$1"
	local "searchfor"="$2"
	local "replacewith"="$3"
	echo ${instr//$searchfor/$replacewith}
} #end_string_replaceAll
