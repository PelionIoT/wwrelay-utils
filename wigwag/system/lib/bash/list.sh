#!/bin/bash

list_print(){
	local inlist="$1"
	local optionalmessage="$2"
	 IFS=" " read -ra quickray <<< "$inlist"
	 if [[ "$optionalmessage" != "" ]]; then
    	echo -e "$optionalmessage"
    fi
    local count=0;
    for element in "${quickray[@]}"; do
      echo -e "\t$count) $element"
      count=$(($count + 1))
    done

}