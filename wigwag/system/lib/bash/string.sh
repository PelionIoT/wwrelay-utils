#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------
# string libary utils
#---------------------------------------------------------------------------------------------------------------------------
#source array.sh
#/	Desc:	removes all newlines from a string
#/	Ver:	.1
#/	$1:		string
#/	Out:	string
#/	Expl:	out=$(string_removeAllNewlines string)
string_removeAllNewlines(){
	echo "${1//'\n'/}" 
} #end_string_removeAllNewlines

string_test(){
	log debug "this is from string $(pwd)"
	echo "string is working"
}
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

string_regex(){
	local instr="$1"
	local regex="$2"
	local retPosition="$3"
	if [[ $instr =~ $regex ]]; then
		echo "${BASH_REMATCH[$retPosition]}"
	else 
		echo "nomatch"
	fi
}

string_chr() {
	[ "$1" -lt 256 ] || return 1
	printf "\\$(printf '%03o' "$1")"
}

string_ord() {
	LC_CTYPE=C printf '%d' "'$1"
}

#must have ascii installed
string_ord_ascii(){
	ascii -t "$1"

}

string_print_ord(){
	local foo="$1"
	for (( i=0; i<${#foo}; i++ )); do
		chari="${foo:$i:1}"
		ord=$(string_ord_ascii $chari)
		echo -e "'$chari'[$ord]"
	done
	#$(echo "$1" | sed -e 's/\(.\)/\1\n/g')
}


#---------------------------------------------------------------------------------------------------------------------------
# utils Testing
#---------------------------------------------------------------------------------------------------------------------------

regextest(){
	string="\"zlib\" [label=\"zlib :1.2.8-r0\n/builds/walt/42/wwrelay-rootfs/yocto/meta/recipes-core/zlib/zlib_1.2.8.bb\"]"
	regex=".*:.*\\n(.*)(\"\])"
	string_regex "$string" "$regex" 1
}
#regextest