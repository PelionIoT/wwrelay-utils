#!/bin/bash
capStatus(){
	local hascaps=0;
	local haslower=0;
	str="$1"
	echo "$str" | grep [A-Z] >> /dev/null 2>&1
	if [[ "$?" = "0" ]]; then
		hascaps=1;
	fi
	echo "$str" | grep [a-z] >> /dev/null 2>&1
	if [[ "$?" = "0" ]]; then
		haslower=1;
	fi
	if [[ $hascaps -eq 1 && $haslower -eq 1 ]]; then
		echo "both"
	elif [[ $hascaps -eq 1 && $haslower -eq 0 ]]; then
		echo "allcaps"
	else
		echo "alllower"
	fi
}





deref(){
	a=${1}_$2
	a=${!a}
	echo "$a"
}


edump="";
MENUDEFERROR(){
	item="$1"
	errortype="$2"
	estart="MENU DEFINITON ERROR"
	#echo "$item $errortype"
	if [[ $errortype -eq 1 ]]; then
	 	edump="$edump\n$item(){\n\t:\n}"
	elif [[ $errortype -eq 2 ]]; then
		edump="$edump\n${item}_DESCRIPTION=\"some descriptive text\""
	elif [[ $errortype -eq 3 ]]; then
		edump="$edump\n${item}_TITLE=\"some title text\""
	fi
}

interpMenuStructure(){
	IFS=" " read -ra currentMenuRay <<< "${!1}"
	 	#create _arrays for each value in ALLMENUS
 	eval "${1}_array=()"
	for item in "${currentMenuRay[@]}"; do
		#echo "$item: ${!item}"
		cstatus=$(capStatus $item)
		DESC=$(deref $item DESCRIPTION)
		TITLE=$(deref $item TITLE)
		isFUNC=$(type -t "$item")

		if [[ "$DESC" = "" ]]; then
			MENUDEFERROR $item 2
		fi
	#	MENUBUILDER_array+=("$item")
	eval "${1}_array+=(\"$item\")"
	eval "${1}_array+=(\"$DESC\")"	
		#echo "$cstatus cstatus"
		if [[ "$cstatus" = "allcaps" ]]; then
			if [[ "$TITLE" = "" ]]; then
				MENUDEFERROR $item 3
			fi
			ALLMENUS+=("$item");
			interpMenuStructure "$item"	
		elif [[ "$cstatus" = "alllower" ]]; then
			if [[ "$isFUNC" != "function" ]]; then
				MENUDEFERROR $item 1
			fi
		else #mixedCase
			if [[ "$TITLE" = "" ]]; then
				MENUDEFERROR $item 3
			fi
			if [[ "$isFUNC" != "function" ]]; then
				MENUDEFERROR $item 1
			fi
		fi
	done
}






DBradioStringBuilder(){
	key="$1"
	name="$2[@]"
	dataray=("${!name}")
	dataraylen=${#dataray[@]}
	for (( i=0; i<$dataraylen; i=i+2)); do
		a="${dataray[$i]}"
		b="${dataray[$i+1]}"
		if [[ "$a" = ${db[$key]} ]]; then
			buildstring="$buildstring$a|$b|ON|";
		else
			buildstring="$buildstring$a|$b|OFF|";
		fi
	done
	echo "$buildstring"
}


renderRadioWithDBMemory(){
	key="$1"
	title=$(deref $key TITLE)
	longDescription=$(deref $key LONGDESCRIPTION)
	shortDescription=$(deref $key DESCRIPTION)
	if [[ "$longDescription" != "" ]]; then
		useDescription="$longDescription"
	elif [[ "$shortDescription" != "" ]]; then
		useDescription="$shortDescription"
	else
		useDescription="";
	fi
	rayname=$key"_ray"
	prerayname=$key"_radioray"
	# echo "title: $title"
	# echo "description: $description"
	# echo "rayname: $rayname"
	radiostring=$(DBradioStringBuilder "$key" "$prerayname")
	IFS='|' read -a $rayname <<< "$radiostring"
	out=$(wp-whip wp-radio "$title" "$useDescription" $rayname)
	if [[ "$out" != "CANCELPRESSED" ]]; then
		db["$key"]="$out";
		database_save
	fi
}


DBlistStringBuilder(){
	key="$1"
	name="$2[@]"
	dataray=("${!name}")
	dataraylen=${#dataray[@]}
	for (( i=0; i<$dataraylen; i=i+2)); do
		a="${dataray[$i]}"
		b="${dataray[$i+1]}"
		if [[ "ON" = ${db["$a"]} ]]; then
			buildstring="$buildstring$a|$b|ON|";
		else
			buildstring="$buildstring$a|$b|OFF|";
		fi
	done
	echo "$buildstring"
}





menusystem_renderList(){
	key="$1"
	title=$(deref $key TITLE)
	longDescription=$(deref $key LONGDESCRIPTION)
	shortDescription=$(deref $key DESCRIPTION)
	if [[ "$longDescription" != "" ]]; then
		useDescription="$longDescription"
	elif [[ "$shortDescription" != "" ]]; then
		useDescription="$shortDescription"
	else
		useDescription="";
	fi
	rayname=$key"_ray"
	prerayname=$key"_listray"
	hastic=$(array_valueContains $prerayname "[\']+")
	#log debug "hastic $hastic"
	if [[ $hastic != 0 ]]; then
		log error "${MAGENTA}[${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}]${NORM}: $prerayname [$hastic] has a ' mark and this is unacceptable."
		exit
	fi
	echo "title: $title"
	echo "description: $description"
	echo "rayname: $rayname"
	#log "debug" "calling database_dump"
	#database_dump
	IFS='|' read -a $rayname <<< $(DBlistStringBuilder "$key" "$prerayname")
	out=$(wp-whip wp-check "$title" "$useDescription" $rayname)
	out="${out//\" \"/|}"
	out="${out//\"/}"
	#log "debug" "my out is $out"
	if [[ "$out" != "CANCELPRESSED" ]]; then
		IFS='|' read -a outray <<< $out
		name="$rayname[@]"
		origkey=("${!name}");
		origkeylen=${#origkey[@]};
		for (( i=0; i<$origkeylen; i=i+3)); do
			a="${origkey[$i]}"
			db["$a"]="OFF";
		done
		for qkey in "${outray[@]}"; do 
		log "debug" "setting $qkey as ON"
		db["$qkey"]="ON";
	done
	database_save
fi
	# echo "the pie is at " db["Rpi-poky-morty"];
	#  echo "read x"
	# read x
}

renderList(){
	log_depricated "renderList" "menusystem_renderlist" "[${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}]"
	menusystem_renderList "$@"
}

renderDirectoryPickerWithDBMemory(){
	key="$1"
	title=$(deref $key TITLE)
	longDescription=$(deref $key LONGDESCRIPTION)
	shortDescription=$(deref $key DESCRIPTION)
	if [[ "$longDescription" != "" ]]; then
		useDescription="$longDescription"
	elif [[ "$shortDescription" != "" ]]; then
		useDescription="$shortDescription"
	else
		useDescription="";
	fi
	# val=${db["$key"]};
	# echo "$val"
	# exit
	out=$(wp-whip wp-dirselect ${db["$key"]} )
	if [[ "$out" != "CANCELPRESSED" ]]; then
		#log "debug" "$key $out"
		database_set "$key" "$out"
	fi
}





stateisMenu(){
	local seeking="$state"
	local in=0
	for element in "${ALLMENUS[@]}"; do
		#echo "ok ALLMENUS elemelent: $element looking for $seeking"
		if [[ "$element" == "$state" ]]; then
			in=1
			break
		fi
	done
	echo $in
}


stack_new menuStack
menusystem_menuLauncher(){
	state=$1;
	next=$state;
	lastState="$2";
	rtn=$(stateisMenu)
	#echo "My state: $state is it a menu? $rtn"
	if [[ $rtn -eq 1 ]]; then
		stack_pop menuStack last
		stack_push menuStack "$last"
		if [[ "$last" != "$state" ]]; then
			stack_push menuStack "$state"
		fi
		#stack_print menuStack
		mtitle=$(deref $state TITLE)
		mdesc=$(deref $state DESCRIPTION)
		mrayNAME=${state}_array
		#next=$(wp-whip wp-menu "Main" "main Menu" menu_main_ray);
		# echo "mtitle: $mtitle"
		# echo "mdesc: $mdesc"
		# echo "mray: $mrayNAME"
		#echo "$lastState" >> out
		next=$(wp-whip wp-menu "$mtitle" "$mdesc" "$mrayNAME" "--default-item $lastState");
	else
		if [[ ${state} != "CANCELPRESSED" ]]; then
			eval ${state}
			if [[ "$next" = "$state" ]]; then
				stack_pop menuStack next
				stack_push menuStack "$next"
			fi
		fi
	fi
	#echo "would call $next"
	menusystem_menuLauncher "$next" "$state";
}

menuLauncher(){
	log_depricated "menuLauncher" "menusystem_menuLauncher" "[${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}]"
	menusystem_menuLauncher "$@"
}
