#---------------------------------------------------------------------------------------------------------------------------
# array library
#---------------------------------------------------------------------------------------------------------------------------

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

#/	Desc:	copies a regular array
#/	Ver:	.1
#/	$1:		named from array
#/	$2:		named to array
#/	Out:	globally the named to array (no output)
#/	Expl:	array_copy from to
array_copy(){
    fromname="$1"
    toname="$2"
    local array="$fromname[@]"
    eval "$toname=()"
    for element in "${!array}"; do
      eval "$toname+=(\"$element\")"
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
	 IFS="$delimeter" read -r -a $namearray <<< "$list"
} #end_PRIVATE_array_createFromGeneric

#/	Desc:	creates array from a space list
#/	Ver:	.1
#/	$1:		named array
#/	$2:		list
#/	Out:	globally outputs the named array
#/	Expl:	array_createFromSpaceList "myray" "cats dogs planes"
array_createFromSpaceList(){
	PRIVATE_array_createFromGeneric "$1" "$2" " "
} #end_array_createFromSpaceList

#/	Desc:	creates array from a comma list
#/	Ver:	.1
#/	$1:		named array
#/	$2:		list
#/	Out:	globally outputs the named array
#/	Expl:	array_createFromSpaceList "myray" "cats,dogs,planes"
array_createFromCommaList(){
	PRIVATE_array_createFromGeneric "$1" "$2" ","
} #end_array_createFromCommaList

#---------------------------------------------------------------------------------------------------------------------------
# utils  associative array
#---------------------------------------------------------------------------------------------------------------------------

#/	Desc:	copies an assoicaitve array
#/	Ver:	.1
#/	$1:		named from array
#/	$2:		named to array
#/	Out:	globally the named to array (no output)
#/	Expl:	associativeArray_copy from to
associativeArray_copy(){
  fromname="$1"
  toname="$2"
  declare -n from="${fromname}"
  eval declare -g -A "${toname}"
  for key in "${!from[@]}"; do
      eval $toname["$key"]="${from["$key"]}"
  done
}

#/	Desc:	prints an assoicative array out to the screen
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
		echo -en "\t$KEY:"
		for (( i = 0; i < $tabcount; i++ )); do
			echo -en "\t"
		done
		echo -en "-${theArray[$KEY]}\n"
	done
  #   echo -en "\n"
  #   outtable="KEY VALUE\n"
  # for KEY in "${!theArray[@]}"; do
  #   VALUE="${theArray[$KEY]}"
  #   outtable="$outtable""$KEY '$VALUE'\n"
  # done
  # echo -e $outtable | column -t
} #end_associativeArray_print




