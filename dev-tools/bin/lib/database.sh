#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------
# quick associative array database (key=>value), accepts only 1 instantiation
#---------------------------------------------------------------------------------------------------------------------------


database=""

#/	Desc:	saves the database
#/	Ver:	.1
#/	Out:	n/a
#/	Expl:	database_save
database_save(){
	declare -g -p db > "$database"
	sed -i 's/declare -A/declare -g -A/' "$database"
} #end_database_save

#/	Desc:	dumps the database to the screen
#/	Ver:	.1
#/	Out:	table on screen
#/	Expl:	database_dump
database_dump(){
	for i in "${!db[@]}"; do
	  echo -e "$i\t\t\t-->\t${db[$i]}"
	done
} #end_database_dump

#/	Desc:	gets the value from from the database, using a key
#/	Ver:	.1
#/	$1:		key
#/	Out:	the stored value
#/	Expl:	output=$(database_get key)
database_get(){
	echo "${db[$1]}"
} #end_database_get

#/	Desc:	sets a default value in database onetime, if its already set and existing, it will not overwrite
#/	Ver:	.1
#/	$1:		key
#/	$2:		value
#/	Out:	n/a
#/	Expl:	database_setDefault Key Value
database_setDefault(){
	if [[ ${db["$1"]} = "" ]]; then
		db["$1"]="$2";
		default_set=1;
	fi
	database_save
} #end_database_setDefault

#/	Desc:	sets overwrites and creates a key value pair
#/	Ver:	.1
#/	$1:		key
#/	$2:		value
#/	Out:	n/a
#/	Expl:	database_set Key Value
database_set(){
	db["$1"]="$2";
	database_save
} #end_database_set

#/	Desc:	searches the database values using a regex
#/	Ver:	.1
#/	$1:		key_regex
#/	$2:		value_regex
#/	$3:		name1
#/	Out:	keys that match as a space-list
#/	Expl:	output=$(database_search "regex" "valueregex" )
database_search(){
	keyx="$1"
	valuex="$2"
	output=""
	for i in "${!db[@]}"; do
		if [[ "$i" =~ $keyx && "${db[$i]}" =~ $valuex ]]; then
	  		output+="$i "
		fi
	done
	echo "$output"
} #end_database_search

#/	Desc:	creates a datbase if it doesn't exist
#/	Ver:	.1
#/	$1:		<database.file>
#/	Out:	n/a
#/	Expl:	database_create /path/to/a/file/mydb.db
database_create(){
	database="$1"
	if [[ ! -e "$database" ]]; then
		echo -e "declare -g -A db='([key]=\"value\")'" > $database
	fi
} #end_database_create

#/	Desc:	erase a dtabase and recreates it as empty
#/	Ver:	.1
#/	Out:	n/a
#/	Expl:	database_erase
database_erase(){
	if [[ -e "$database" ]]; then
		rm -rf "$database"
	fi
	database_create "$database"
} #end_database_erase

