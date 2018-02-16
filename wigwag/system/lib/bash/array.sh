#---------------------------------------------------------------------------------------------------------------------------
# array library
#---------------------------------------------------------------------------------------------------------------------------
# Some help:
# create an array from a list
# 		localhostlist="https://10.10.102.57:8080/newsys/ https://10.10.102.57:8080/newsys/"
# 		array_createFromSpaceList "localhosts" "$localhostlist"
# print an element:
#		echo ${localhosts[0]};
# loop through all elements
#		for element in "${localhosts[@]}"; do
#			echo -e "\t$count) $element"
#			count=$(($count + 1))
#		done

array_announce(){
	echo "hi from test ok"
}
#/	Desc:	checks if an array contains an exact element
#/	Ver:	.1
#/	$1:		name passed array
#/	$2:		search text
#/	Out:	0|1
#/	Expl:	out=$(array_contains array string)
array_contains() { 
local array="$1[@]"
local seeking=$2
local in=0
for element in "${!array}"; do
	if [[ $element == $seeking ]]; then
		in=1
		break
	fi
done
echo $in
} #end_array_contains

#/	Desc:	checks if an array contains an exact element
#/	Ver:	.1
#/	$1:		name passed array
#/	$2:		regex
#/	Out:	0|1
#/	Expl:	out=$(array_contains array string)
array_valueContains() { 
local array="$1[@]"
local seeking=$2
local in=0
for element in "${!array}"; do
#	log debug "checking $element with $seeking"
if [[ $element =~ $seeking ]]; then
	log debug "found $element"
	in="$element"
	break
fi
done
echo $in
} #end_array_valueContains

#/	Desc:	copies a regular array
#/	Ver:	.1
#/	$1:		named from array
#/	$2:		named to array
#/	Out:	globally the named to array (no output)
#/	Expl:	array_copy from to
array_copy(){
	named_inray="$1"
	named_outray="$2"
	local array="$named_inray[@]"
	eval "$named_outray=()"
	for element in "${!array}"; do
		eval "$named_outray+=(\"$element\")"
	done
} #end_array_copy

#/	Desc:	private function that creates arrays from delimted list
#/	Ver:	.1
#/	$1:		named array
#/	$2:		list
#/	$3:		delimeter
#/	Out:	globally outputs the named array
#/	Expl:	PRIVATE_array_createFromGeneric "arrayname" "thelist" "delimeter"
PRIVATE_array_createFromGeneric(){
	namearray="$1"
	local list="$2"
	local delimeter="$3"
	#echo "my name arrayou $namearray"
	IFS="$delimeter" read -r -a $namearray <<< "$list"
	#IFS="$delimeter" read -r -a shit <<< "$list"
	#echo ${enabledPokyBranches2[0]}
} #end_PRIVATE_array_createFromGeneric


array_merge(){
	local first="$1[@]"
	local second="$2[@]"
	out_ray="$3"
	three=("${!first}" "${!second}")
	array_copy three "$out_ray"
}

#/	Desc:	removes duplicates from an array
#/	Ver:	.1
#/	$1:		named array
#/	Out:	evaled array by the same name as called
#/	Expl:	array_removeduplicates namedRay
array_removeduplicates(){
	named_inray="$1"
	named_outray="$2"
	local ray="$named_inray[@]"
	declare -A theAssocRay
	for i in "${!ray}"; do 
	#echo "my i is '$i'"
	theAssocRay["$i"]=1 
done
#associativeArray_print theAssocRay
associativeArray_KeyToArray theAssocRay "$named_outray"
}
#/	Desc:	evals each filed in an array (b is the field)
#/	Ver:		.1
#/	$1:		cmd
#/	$2:		named array
#/	Out:		xxx
#/	Expl:	array_eval "echo \$b" myray  -> prints each item in the array
array_eval(){
	cmd="$1"
	inray="$2[@]"
	local count=0
	for b in "${!inray}"; do
		#echo "ok my flipbit is $b"
		eval "$cmd"
		count=$(($count + 1 ))
	done
}

#/	Desc:	runs a regex on each element and returns a new array
#/	Ver:	.1
#/	$1:		named inarray
#/	$2:		named outarray
#/  $3:		regexfilter
#/	Out:	evaled outarray
#/	Expl:	array_regex namedInRay named_outray regex
#/	Expl:	array_regex disabledPokyBranches disabledBranchNames "\"\${b/*-poky-/}\""
array_regex(){
	local named_inray="$1[@]"
	local named_outray="$2"
	local regex="$3"
	eval "$named_outray=()"
	for b in "${!named_inray}"; do
		#eval "$named_outray+=(\"${b/*-poky-/}\")"
		eval "$named_outray+=($3)"
	done
}

#/	Desc:	returns the merge of two arrays including duplicates
#/	Ver:	.1
#/	$1:		named in_leftR_array
#/	$2:		named in_rightR_array
#/  $3:		named out_array
#/	Out:	evaled out_array
#/	Expl:	array_unionAll leftR rightR union
array_unionAll(){
	local one=""
	local two=""
	array_copy "$1" one
	array_copy "$2" two
	array_removeduplicates one onea
	array_removeduplicates two twoa
	array_merge onea twoa "$3"
} #end_array_unionAll

#/	Desc:	returns the merge of two arrays including duplicates
#/	Ver:	.1
#/	$1:		named in_left_array
#/	$2:		named in_rightR_array
#/  $3:		named out_array
#/	Out:	evaled out_array
#/	Expl:	array_unionAll left rightR union
array_union(){
	array_unionAll "$1" "$2" aout
	array_removeduplicates aout "$3"
} #end_array_unionAll


array_intersection(){
	local leftR="$1[@]"
	local rightR="$2[@]"
	named_outray="$3"
	eval "$named_outray=()"
	outR=();
	for left_val in ${!leftR}; do
		for right_val in ${!rightR}; do
			if [[ "$left_val" = "$right_val" ]]; then
				eval "$named_outray+=(\"$left_val\")"
				outR+=("$left_val");
			fi
		done
	done
	array_removeduplicates outR "$named_outray"
} #end_array_intersection


array_minus(){
	local leftR="$1[@]"
	local rightR="$2[@]"
	named_outray="$3"
	eval "$named_outray=()"
	outR=();
	for left_val in ${!leftR}; do
		amatch=0;
		for right_val in ${!rightR}; do
			if [[ "$left_val" = "$right_val" ]]; then
				amatch=1;
			fi
		done
		if [[ $amatch -eq 0 ]]; then
			eval "$named_outray+=(\"$left_val\")"
			outR+=("$left_val");
		fi
	done
	array_removeduplicates outR "$named_outray"
}
array_except(){
	array_minus "$1" "$2" "$3"
}
#/	Desc:	creates array from a space list
#/	Ver:	.1
#/	$1:		named inarray
#/	$2:		list
#/	Out:	globally outputs the named array
#/	Expl:	array_createFromSpaceList "myray" "$alist"
array_createFromSpaceList(){
	PRIVATE_array_createFromGeneric "$1" "$2" " "
} #end_array_createFromSpaceList

#/	Desc:	creates array from a comma list
#/	Ver:	.1
#/	$1:		named array
#/	$2:		list
#/	Out:	globally outputs the named array
#/	Expl:	array_createFromCommaList "myray" "cats,dogs,planes"
array_createFromCommaList(){
	PRIVATE_array_createFromGeneric "$1" "$2" ","
} #end_array_createFromCommaList

#/	Desc:	creates array from a dot list
#/	Ver:		.1
#/	$1:		named array
#/	$2:		list
#/	Out:		globally outputs the named array
#/	Expl:	array_createFromDotList "myray" "major.minor.update"
array_createFromDotList(){
	PRIVATE_array_createFromGeneric "$1" "$2" "."
} #end_array_createFromDotList

#/	Desc:	creates array from a new line list
#/	Ver:	.1
#/	$1:		named array
#/	$2:		list
#/	Out:	globally outputs the named array
#/	Expl:	array_createFromNewLineList "myray" "listwithnewlines"
array_createFromNewLineList(){
	namearray="$1"
	local list="$2"
	readarray -t $namearray <<< "$list"
}

array_createFromNewLineFile(){
	namearray="$1"
	local infile="$2"
	array_createFromNewLineList "$namearray" "$(cat $infile)"
}

array_print(){
	named_inray="$1"
	optionalmessage="$2"
	local array="$named_inray[@]"
	if [[ "$optionalmessage" != "" ]]; then
		echo -e "$optionalmessage"
	fi
	local count=0;
	for element in "${!array}"; do
		echo -e "\t$count) $element"
		count=$(($count + 1))
	done
}
#---------------------------------------------------------------------------------------------------------------------------
# utils  associative array
# examples http://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/
#---------------------------------------------------------------------------------------------------------------------------

associativeArray_create(){
	eval declare -g -A "${1}"
}


#/	Desc:	copies an associative array
#/	Ver:	.1
#/	$1:		named from array
#/	$2:		named to array
#/	Out:	globally the named to array (no output)
#/	Expl:	associativeArray_copy from to
associativeArray_copy(){
	named_inray="$1"
	named_outray="$2"
	declare -n from="${named_inray}"
	eval declare -g -A "${named_outray}"
	for key in "${!from[@]}"; do
		eval $named_outray["$key"]="${from["$key"]}"
	done
}

#/	Desc:	converts all associative array keys to a regular array
#/	Ver:	.1
#/	$1:		named associative array
#/	$2:		named list
#/	Out:	evaled to the named list passed in
#/	Expl:	associativeArray_KeyToList myAray mylist
associativeArray_KeyToList(){
	declare -n ray="$1"
	local other="$2"
	local outlist=""
	for key in "${!ray[@]}"; do
		outlist="$key $outlist"
		#echo "my key $key"
	done
	eval "$other=\$outlist"
}

associativeArray_KeyToArray(){
	declare -n ray="$1"
	myregray="$2"
	eval "$myregray=()"
	tlist=""
	for key in "${!ray[@]}"; do
		eval "$myregray+=(\"$key\")"
	done
	# associativeArray_KeyToList "$Aray" "tlist"
	# echo "hey my tlist: '$tlist'"
	# exit
	# # echo "hey my reg $myregray"
	# # echo "and hey my $tlist"
	# array_createFromSpaceList "$myregray" "$tlist"
}

#/	Desc:	gets the value from from the associativeArray, using a key
#/	Ver:	.1
#/	$1:		key
#/	Out:	the stored value
#/	Expl:	output=$(associativeArray_get key)
#/	NOTE: because of the way the echo works, capturing using a (command substitution), the return value gets stripped
#	 	 of newlines in some cases as a workaround use the IFS process subtitution tecnique documented here: 
#	 	 http://stackoverflow.com/questions/15184358/how-to-avoid-bash-command-substitution-to-remove-the-newline-character
#		 e.g. IFS= read -rd '' avarrible < <( associativeArray_get "$thekey")
#		 Another more simple way is to use the db directly var=${db[$key]}
associativeArray_get(){
	local inray="$1"
	locout="${["$1"]}"
	#log error "'$locout'"
	echo "$locout"

} #end_associativeArray_get

associativeArray_append(){
	local named_inray="$1"
	declare -n copy_inray="$1"
	local inkey="$2"
	local indata="$3"
	local indelinator="$4"
	if [[ "$indelinator" = "" ]]; then
		indelinator=$'\n'
		#indelinator=$(printf "\x$(printf %x 65)")
		#indelinator="x"
	fi
	#echo "$named_inray $inkey $indata $indelinator"
	#echo "xxx"$(eval ${!named_inray["$inkey"]})
	cVal1="${copy_inray["$inkey"]}"
	#echo "hey my cVal1 '$cVal1'"
	if [[ "$cVal1" != "" ]]; then
		cVal="$cVal1$indelinator$indata"
	else
		cVal="$indata"
	fi
	#echo "hey ny cVal '$cVal'"
	#eval $named_inray["$key"]="${from["$key"]}"
	eval "$named_inray[\"$inkey\"]=\"$cVal\""
}


#/	Desc:	prints an associative array out to the screen
#/	Ver:	.1
#/	$1:		array to print
#/	$2:		name1
#/	$3:		name1
#/	Out:	printed array
#/	Expl:	associativeArray_print myray
associativeArray_print(){
	declare -n theArray=$1
	echo -en "$1 (${#theArray[@]} records)\n-------------------------------------------------------------------------------------------------------------------------------------------\n"
	for KEY in "${!theArray[@]}"; do
		len=${#KEY}
		tabcount=$(( 5 - ( $len / 4 ) ))
		taby="\t"
		echo -e "$taby$KEY:"
		taby="\t\t\t\t"
		# for (( i = 0; i < $tabcount; i++ )); do
		# 	taby="$taby\t"
		# 	#echo -en "\t"
		# done
		array_createFromNewLineList pvalue "${theArray[$KEY]}"
		for mline in "${pvalue[@]}"; do
			echo -en "$taby$mline\n"
		done
	done
  #   echo -en "\n"
  #   outtable="KEY VALUE\n"
  # for KEY in "${!theArray[@]}"; do
  #   VALUE="${theArray[$KEY]}"
  #   outtable="$outtable""$KEY '$VALUE'\n"
  # done
  # echo -e $outtable | column -t
} #end_associativeArray_print


#---------------------------------------------------------------------------------------------------------------------------
# tests  
#---------------------------------------------------------------------------------------------------------------------------
arraytest_1(){
	arr1=("one" "two" "three" "three")
	arr2=("two" "four" "six" "four")
	outray=""
	echo "array 1 contents:"
	array_print arr1
	echo "array 2 contents:"
	array_print arr2
	echo "first lets merge two arrays"
	array_merge arr1 arr2 outray
	array_print outray
	echo "next lets remove the duplicates from the merge"
	array_removeduplicates outray outray2
	array_print outray2
	echo "a union: all the unique rows from the arr1 and arr2"
	array_union arr1 arr2 newoutray
	array_print newoutray
	echo "a unionAll: all the unique rows from the arr1 and arr2, with duplicates"
	array_unionAll arr1 arr2 newoutray
	array_print newoutray
	echo "a intersection: all the common unique rows from both arrays"
	array_intersection arr1 arr2 newoutray
	array_print newoutray
	echo "a except: unique rows from the left array that are not in right"
	array_except arr1 arr2 newoutray
	array_print newoutray
}

associativetest_1(){
	associativeArray_create test1
	associativeArray_append test1 "mykey" "value1"
	associativeArray_append test1 "mykey" "value2"
	associativeArray_print test1
}

#arraytest_1
#associativetest_1
#
list_print(){
	list="$1"
	local li=0;
	local count=0;
	for e in $list; do
		echo -e "$li)\t$e"
		li=$((li + 1))
	done
}

list_eval(){
	cmd="$1"
	list="$2"
	local count=0;
	local li=0;
	for b in $list; do
		#echo "ok my flipbit is $b"
		eval "$cmd"
		count=$((count + 1 ))
	done
}