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

#---------------------------------------------------------------------------------------------------------------------------
# quick associative array database (key=>value), accepts only 1 instantiation
# To use this you must have the following two lines
# database_create "../data/buildmaster.db"
# source "../data/buildmaster.db"

#---------------------------------------------------------------------------------------------------------------------------
#old ones to search
#DBsave
#DBsearch
#DBset
#
#

database=""

dbloglevel="silly"
dbloglevel=""

debug_database=0;

debugcmd(){
	if [[ $debug_database -eq 1 ]]; then
		eval "$1"
	fi
}

#/	Desc:	creates a datbase if it doesn't exist
#/	Ver:	.1
#/	$1:		<database.file>
#/	Out:	n/a
#/	Expl:	database_create /path/to/a/file/mydb.db
database_create(){
	database="$1"
	log "$dbloglevel" "database_create $1"
	if [[ ! -e "$database" ]]; then
		#log "debug3" "inside the create because it doesn't exist"
		echo -e "declare -g -A db='([key]=\"value\")'" > $database
		debugcmd "cat $database"
	fi
	#log "$dbloglevel" "done with dtabase_create"

} #end_database_create

#/	Desc:	saves the database
#/	Ver:	.1
#/	Out:	n/a
#/	Expl:	database_save
database_save(){
	#local dbloglevel="silly"
	#log "$dbloglevel" "save called on $database"
	declare -g -p db > "$database"
	#log "$dbloglevel" "save doing the sed command"
	sed -i 's/declare -A/declare -g -A/' "$database"
	#debugcmd "cat $database"
	#log "debug" "lets cat"
	#currentdb=$(cat $database)
	#log "debug" "currentdb in the save: $currentdb"
	#log "$dbloglevel" "done with save"
} #end_database_save

#/	Desc:	dumps the database to the screen
#/	Ver:	.1
#/	Out:	table on screen
#/	Expl:	database_dump
database_dump(){
	log "$dbloglevel" "dump called on $database"
	for i in "${!db[@]}"; do
		echo -e "$i\t\t\t--\t${db[$i]}"
	done
} #end_database_dump

#/	Desc:	gets the value from from the database, using a key
#/	Ver:	.1
#/	$1:		key
#/	Out:	the stored value
#/	Expl:	output=$(database_get key)
#/	NOTE: because of the way the echo works, capturing using a (command substitution), the return value gets stripped
#	 	 of newlines in some cases as a workaround use the IFS process subtitution tecnique documented here: 
#	 	 http://stackoverflow.com/questions/15184358/how-to-avoid-bash-command-substitution-to-remove-the-newline-character
#		 e.g. IFS= read -rd '' avarrible < <( database_get "$thekey")
#		 Another more simple way is to use the db directly var=${db[$key]}
database_get(){
#	echo "${db[$1]}"
	locout="${db["$1"]}"
	#log error "'$locout'"
	echo "$locout"

} #end_database_get

#/	Desc:	sets a default value in database onetime, if its already set and existing, it will not overwrite
#/	Ver:	.1
#/	$1:		key
#/	$2:		value
#/	Out:	n/a
#/	Expl:	database_setDefault Key Value
database_setDefault(){
	log "$dbloglevel" "settingDefault $1=$2"
	if [[ ${db["$1"]} = "" ]]; then
		db["$1"]="$2";
		#default_set=1;
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
	#log "$dbloglevel" "database_set '$1' '$2'"
	#log "silly" "database_set '$1' '$2'"
	#log "debug" "dump1"
	#database_dump
	db["$1"]="$2";
	#log "debug" "dump2"
	#database_dump
	#log debug "saving"
	database_save
	#log debug "dump 3"
	#database_dump
} #end_database_set


database_increment(){
	db["$1"]=$((${db["$1"]} + 1))
	database_save
}

database_decrement(){
	db["$1"]=$((${db["$1"]} - 1))
	database_save
}


#/	Desc:	appends to a value with a delimiter (zero spacing)
#/	Ver:		.1
#/	$1:		KEY
#/	$2:		appendData
#/	$3:		delinator
#/	Out:		n/a
#/	Expl:	database_append "KEY" "Value" "delinator"
#/	demo:	database_append "Names" "Travis" ","
database_append(){
	local inkey="$1"
	local indata="$2"
	local indelinator="$3"
	local curval="${db[$inkey]}"
	if [[ "$curval" != "" ]]; then
		curval="$curval""$indelinator""$indata"
	else
		curval="$indata"
	fi
	database_set "$inkey" "$curval"
}

#/	Desc:	builds a newline list within the value cell
#/	Ver:		.1
#/	$1:		key
#/	$2:		value to append
#/	Out:	n/a
#/	Expl:	database_append_nll Key Value
database_append_nll(){
	database_append "$1" "$2" $'\n'
	#database_append "$1" "$2" "$(printf "\x4A")"
	#database_append "$1" "$2" "X"
	#database_append "$1" "$2" "\\n"
}
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
		#log "debug" "$i  $keyx && ${db[$i]}  $valuex"
		# log debug "called from [${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}]"
		if [[ "$i" =~ $keyx && "${db[$i]}" =~ $valuex ]]; then
	  		output+="$i "
		fi
	done
	echo "$output"
} #end_database_search



ddd(){
	keyx="$1"
	valuex="$2"
	output=""
	for alldb in "${!db[@]}"; do
		 # log debug "called from [${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}]"
		#if [[ "$alldb" =~ $keyx ]]; then
		if [[ "$alldb" =~ $keyx && "${db[$alldb]}" =~ $valuex ]]; then
		# log "debug" "$alldb  $keyx && ${db[$alldb]} ---  $valuex"
		# 	echo "hey $alldb"
		output+="$alldb "
	fi
done
echo "'$output'"
} #end_database_search

#/	Desc:	erase a dtabase and recreates it as empty
#/	Ver:	.1
#/	Out:	n/a
#/	Expl:	database_erase
database_erase(){
	log "$dbloglevel" "database_erase $database"
	if [[ -e "$database" ]]; then
		rm -rf "$database"
	fi
	database_create "$database"
} #end_database_erase



