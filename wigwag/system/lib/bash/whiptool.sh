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

wt=$(which whiptail)
wd=$(which dialog)
wr=$(which resize)
if [[ ! -e $wt ]]; then
    displayDependancies="whiptail\t\tsudo apt-get install whiptail"
fi
if [[ ! -e $wd ]]; then
    displayDependancies="$displayDependancies\ndialog\t\tsudo apt-get install dialog"
fi
if [[ ! -e $wr ]]; then
    displayDependancies="$displayDependancies\nresize\t\tsudo apt-get install xterm"
fi
if [[ $displayDependancies != "" ]]; then
    echo -e "Missing Dependancies\n"
    echo -e "$displayDependancies\n"
    exit
fi




wp-raytype() {
    title="${1}"
    mtype="${2}"
    mtype_desc="${3}"
    rayname="$4"
    otheroptions="$5"
    #echo -e  "title: $title\nmtype: $mtype\nmtype_desc: $mtype_desc\nrayname: $rayname\notheroptions: $otheroptions"
    eval `resize`
    wpstring="whiptail --title '$title' $mtype '$mtype_desc' $otheroptions $LINES $COLUMNS $(($LINES - 8))"
    wpstring=$(wp-rayadd "$wpstring" "$4")
    #echo "$wpstring" > out
    RESULT=$(wp-eval "$wpstring")   
    echo "$RESULT"
}



wp-rayadd(){
    wpstring="$1"
    name="$2[@]"
    dataray=("${!name}")
#echo -e "$wpstring $name $dataray"

for i in "${dataray[@]}" ; do
    if [ "$i" != "ON" ] && [ "$i" != "OFF" ]; then
        wpstring="$wpstring '$i'";
    else
        wpstring="$wpstring $i"
    fi
done
echo "$wpstring"
}


wp-eval(){
    RESULT2=$(eval $wpstring 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [[ $exitstatus -ne 0 ]]; then
        echo "CANCELPRESSED"
    else
        echo "$RESULT2"
    fi
}



wp-radio () {
    RESULT=$(wp-raytype "${1}" "--radiolist" "$2" $3)
    echo "$RESULT"
}

wp-check () {
    RESULT=$(wp-raytype "${1}" "--checklist" "$2" $3)
    echo "$RESULT"
}



wp-menu(){
    echo "--menu $2 $3 $4" >> out
    RESULT=$(wp-raytype "${1}" "--menu" "$2" $3 "$4" )
    echo "$RESULT" 
}

wp-input () {
    eval `resize`
    wpstring="whiptail --title '$1' --inputbox '$2' $LINES $COLUMNS '$3'"
    RESULT=$(wp-eval "$wpstring")   
    echo "$RESULT"
}

wp-pass () {
    eval `resize`
    wpstring="whiptail --title '$1' --passwordbox '$2' $LINES $COLUMNS '$3'"
    RESULT=$(wp-eval "$wpstring")   
    echo "$RESULT"
}

wp-msg () {
    divisor=$3
    eval `resize`
    if [[ $divisor != "" ]]; then
        LINES=$(( $LINES / $divisor ))
        COLUMNS=$(( $COLUMNS / $divisor ))
    fi
    wpstring="whiptail --title '$1' --msgbox '$2' $LINES $COLUMNS "
    RESULT=$(wp-eval "$wpstring")   
    echo "DONE"
}
wp-infobox(){
    eval `resize`
    wpstring="dialog --title '$1' --infobox '$2' $LINES $COLUMNS; sleep $3"
    RESULT=$(wp-eval "$wpstring")   
    echo "DONE"
}
wp-file () {
    eval `resize`
    wpstring="whiptail --title '$1' --textbox $2 $LINES $COLUMNS"
    RESULT=$(wp-eval "$wpstring")   
    echo "DONE"
}

wp-yesno () {
    title="$1"
    message="$2"
    eval `resize`
    wpstring="whiptail --title '$title' --yesno '$message' $LINES $COLUMNS"
    RESULT2=$(eval $wpstring 3>&1 1>&2 2>&3)
    RESULT2=$?
    if [ $RESULT2 = 0 ]; then
        echo "YES"
    else
        echo "NO"
    fi
}

#if calling with a directory, include the trailing /
wp-fileselect(){
    dirpath=$1;
    if [ -f $dirpath ]; then
        fname=$(basename $dirpath)
        fname="--default-item $fname"
        dirpath=$(dirname $dirpath)/
        echo $fname
        echo $dirpath
    fi
    eval `resize`
    if [ -z $dirpath ]; then
        imgpath=$(ls -lhp / | awk -F ' ' ' { print $9 " " $5 } ')
        pathselect=$(whiptail --menu "Select File" $LINES $COLUMNS $(($LINES - 8)) --cancel-button Cancel --ok-button Select $imgpath 3>&1 1>&2 2>&3)
    else
        imgpath=$(ls -lhp "$dirpath" | awk -F ' ' ' { print $9 " " $5 } ')
        pathselect=$(whiptail --menu "Select File" $LINES $COLUMNS $(($LINES - 8)) $fname --cancel-button Cancel --ok-button Select ../ BACK $imgpath 3>&1 1>&2 2>&3)

    fi
    RET=$?
    if [ $RET -eq 1 ]; then
        ## This is the section where you control what happens when the user hits Cancel
        echo "CANCELPRESSED"
    elif [ $RET -eq 0 ]; then
        if [[ -d "/$dirpath$pathselect" ]]; then
            wp-fileselect "/$dirpath$pathselect"
        elif [[ -f "/$dirpath$pathselect" ]]; then
            #a file was selected
            out=$(readlink -f "$dirpath$pathselect")
            echo $out
        else
            #echo pathselect $dirpath$pathselect
            whiptail --title "! ERROR !" --msgbox "Error setting path to image file." 8 44
            exit
            unset dirpath
            unset imgpath
            wp-fileselect
        fi
        exit 0
    fi
}


#if calling with a directory, include the trailing /
wp-dirselect(){
    dirpath=$1;
    dirpath=$(readlink -f "$1")
    # if [ -f $dirpath ]; then
    #         fname=$(basename $dirpath)
    #         fname="--default-item $fname"
    #         dirpath=$(dirname $dirpath)/
    #         echo $fname
    #         echo $dirpath
    # fi
    eval `resize`
    thisdir=". select-this-directory .. back-one-directory"
    mkdirmark="mkdir"
    injectMenuChoices="$mkdirmark create-directory"
    if [ -z $dirpath ]; then
        imgpath=$(ls -lhp / | grep '^d' | awk -F ' ' ' { print $9 " " $5 }')
        #imgpath=$(ls -lhp / | awk -F ' ' ' { print $9 " " $5 } ')
        pathselect=$(whiptail --menu "$dirpath" $LINES $COLUMNS $(($LINES - 8)) --cancel-button Cancel --ok-button Select $injectMenuChoices ' ' ' ' $thisdir $imgpath 3>&1 1>&2 2>&3)
    else
        imgpath=$(ls -lhp "$dirpath" | grep '^d' | awk -F ' ' ' { print $9 " " $5 }')
        #imgpath=$(ls -lhp "$dirpath" | awk -F ' ' ' { print $9 " " $5 } ')
        pathselect=$(whiptail --menu "$dirpath" $LINES $COLUMNS $(($LINES - 8)) $fname --cancel-button Cancel --ok-button Select  $injectMenuChoices ' ' ' ' $thisdir $imgpath 3>&1 1>&2 2>&3)
    fi
    RET=$?
    #echo -e "\t 9: $pathselect" >> testout
    if [ $RET -eq 1 ]; then
        ## This is the section where you control what happens when the user hits Cancel
        #echo "CANCEL" >> testout
        echo "CANCELPRESSED"
    elif [ $RET -eq 0 ]; then
        #echo -e "\t\t 8: $dirpath/$pathselect -d test" >> testout
        if [[ -d "$dirpath/$pathselect" ]]; then
            #echo -e "\t\t\t 7: inside the iff" >> testout
            if [[ "$pathselect" = "." ]]; then
               out=$(readlink -f "$dirpath/$pathselect")
               echo $out
           else
            dirpath=$(readlink -f $dirpath/$pathselect);
                #echo "s1: $dirpath" >> testout
                wp-dirselect "$dirpath"
            fi
        elif [[ -f "/$dirpath/$pathselect" ]]; then
            #a file was selected
            #echo "selectafile $dirpath"
            #333whiptail --title "! ERROR !" --msgbox "Do not select a file. Select a directory!" $LINES $COLUMNS
            something=$(wp-getResults wp-msg "! ERROR !" "Do not select a file.  Select a directory!" 2)
            #exit
            dirpath=$(readlink -f $dirpath);
            #echo "s2: $dirpath/" >> testout
            wp-dirselect "$dirpath/"
        elif [[ "$pathselect" = "$mkdirmark" ]]; then
            newdir=$(wp-getResults wp-input "mkdir" "entere the directory name (no error checking -be careful)" "")
            dirpath=$(readlink -f $dirpath)
            mkdir $dirpath/$newdir
            wp-dirselect "$dirpath/$newdir"
        else
            #echo pathselect $dirpath$pathselect
            something=$(wp-getResults wp-msg "! ERROR !" "In the else!" 2)
            exit
            unset dirpath
            unset imgpath
            #echo "s3: /" >> testout
            wp-dirselect "/"
        fi
        exit 0
    fi
}




wp-getResults(){
    RES=$("$@");
    echo "$RES"
}

#if your looking for whip, i had to kill it because of sourcing whip() so p
wp-whip(){
    RES=$("$@");
    echo "$RES"
}

wp-help(){
    echo "help is here.. expand"
}
# Usage info
show_help() {
    log_removed "show_help" "wp-help" "the EOF stuff in show_help was causing sourcing errors"
    # cat << EOF
    # Usage: ${0##*/} [-hv] [-f OUTFILE] [FILE]...
    # Do stuff with FILE and write the result to standard output. With no FILE
    # or when FILE is -, read standard input.
    
    # -h          display this help and exit
    # -f OUTFILE  write the result to OUTFILE instead of standard output.
    # -v          verbose mode. Can be used multiple times for increased
    # verbosity.
    # EOF
}                













testwp () {
    testing=$1
    menu_ray=("<-- Back" "Return to the main menu." "Add User" "Add a user to the system." "Modify User" "Modify an existing user." "List Users" "List all users on the system." "Add Group" "Add a user group to the system." "Modify Group" "Modify a group and its list of members." "List Groups" "List all groups on the system.")
    radio_ray=("<-- Back" "Return to the main menu." ON "Add User" "Add a user to the system." OFF "Modify User" "Modify an existing user." OFF "List Users" "List all users on the system." OFF "Add Group" "Add a user group to the system." OFF "Modify Group" "Modify a group and its list of members." OFF "List Groups" "List all groups on the system." OFF)


    if [[ $testing = "ALL" || $testing = "RADIO" ]]; then
        echo -e "Testing Radio"
        echo -e 'Result: '$(wp-getResults wp-radio "Radio test" "doit" radio_ray)'\n'
    fi
    if [[ $testing = "ALL" || $testing = "LIST" ]]; then
        echo "Testing LIST"
    # echo -e 'Result:res1=$(wp-getResults wp-input "input test" "doit" "default value")
    # res2=$(wp-getResults wp-input "input test" "doit" "default value")
    # res3=$(wp-getResults wp-input "input test" "doit" "default value") '$(wp-getResults wp-check "List test" "doit" radio_ray)'\n'
    echo -e 'Result: '$(wp-getResults wp-check "List test" "doit" radio_ray)'\n'
fi
if [[ $testing = "ALL" || $testing = "MENUS" ]]; then
    echo "Testing Menu"
    echo -e 'Result: '$(wp-getResults wp-menu "Menu test" "doit" menu_ray)'\n'
fi
if [[ $testing = "ALL" || $testing = "INPUT" ]]; then
    echo "Testing input"
    echo -e 'Result: '$(wp-getResults wp-input "input test" "doit" "default value")'\n'
fi
if [[ $testing = "ALL" || $testing = "PASSWORD" ]]; then
    echo "Testing password"
    echo -e 'Result: '$(wp-getResults wp-pass "pass test" "doit" "default value")'\n'
fi
if [[ $testing = "ALL" || $testing = "MESSAGEBOX" ]]; then
    echo "Testing messagebox"
    echo -e 'Result: '$(wp-getResults wp-msg "msg test" "doit now or else now hit ok")'\n'
fi
if [[ $testing = "ALL" || $testing = "FILE" ]]; then
    echo "Testing file"
    echo -e 'Result: '$(wp-getResults wp-file "file test tile menu" "/etc/passwd" )'\n'
fi
if [[ $testing = "ALL" || $testing = "YESNO" ]]; then
    echo "Testing yesno"
    echo -e 'Result: '$(wp-getResults wp-yesno "yesno test text menu" "doit or not you decide")'\n'
fi
if [[ $testing = "ALL" || $testing = "FILESELECT" ]]; then
    echo "Testing wp-fileselect"
    echo -e 'Result: '$(wp-getResults wp-fileselect "/home/")'\n'
fi
if [[ $testing = "ALL" || $testing = "DIRSELECT" ]]; then
    echo "Testing wp-dirselect"
    echo -e 'Result: '$(wp-getResults wp-dirselect "/home/")'\n'
fi
}

#testwp FILESELECT
#exit
