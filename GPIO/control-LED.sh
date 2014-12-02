#!/bin/bash



function getScriptDir() {
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
local __SOURCE=$1
while [ -h "$__SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  local __MYDIR="$( cd -P "$( dirname "$__SOURCE" )" && pwd )"
  local __SOURCE="$(readlink "$__SOURCE")"
  [[ $__SOURCE != /* ]] && local __SOURCE="$__MYDIR/$__SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
local __MYDIR="$( cd -P "$( dirname "$__SOURCE" )" && pwd )"
echo "$__MYDIR"
}

THISDIR=$(getScriptDir "${BASH_SOURCE[0]}")
. $THISDIR/../common/common.sh

# bring GPIO functions most importantly the array
. $THISDIR/../GPIO/setup-gpio.sh funcsonly
SCRIPT=`basename ${BASH_SOURCE[0]}`



#Initialize
MODES="heartbeat mmc0 timer TEST none"
COLORS="red green blue cyan magenta yellow white off black nochange"
#set Options to their defaults (see help section)
OPT_F="nochange"
OPT_T="nochange"
OPT_M="none"
OPT_M="none"



#Help function
function HELP {
  echo -e \\n"Help documentation for ${C_BOLD}${SCRIPT}.${C_NORM}"\\n
  echo -e "${C_REV}Basic usage:${C_NORM} ${C_BOLD}$SCRIPT color ${C_NORM}"\\n
  echo "The following switches are optional."
  echo -e "\t${C_REV}-f${C_NORM} optional [${C_BOLD}${COLORS// /|}${C_NORM}] --Sets only the front LED if equipted.  Default is ${C_BOLD}OFF${C_NORM}."
  echo -e "\t${C_REV}-t${C_NORM} optional [${C_BOLD}${COLORS// /|}${C_NORM}] --Sets only the top LED if equipted. Default is ${C_BOLD}OFF${C_NORM}."
  echo -e "\t${C_REV}-m${C_NORM} optional [${C_BOLD}${MODES// /|}${C_NORM}] --Sets the mode for light strobe. Default is ${C_BOLD}none${C_NORM}."
  echo -e "\t${C_REV}-h${C_NORM}  --Displays this help message. No further functions are performed."\\n
  echo -e "Example: ${C_BOLD}$SCRIPT -f blue -m heartbeat${C_NORM}"\\n
  exit 1
}


#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
#echo -e \\n"Number of arguments: $NUMARGS"
if [ $NUMARGS -eq 0 ]; then
  HELP
fi

### Start getopts code ###

#Parse command line flags
#If an option should be followed by an argument, it should be followed by a ":".
#Notice there is no ":" after "h". The leading ":" suppresses error messages from
#getopts. This is required to get my unrecognized option code to work.

while getopts :f:t:m:h FLAG; do
	TEST="$OPTARG "
	case $FLAG in
    f)
		if [[ "$COLORS" =~ "$TEST" ]]; then
			OPT_F=$OPTARG 
		else	
			echo "${C_RED}${C_BOLD}-f $OPTARG invalid${C_NORM}"
			HELP
		fi
      	;;
    t)
		if [[ "$COLORS" =~ "$TEST" ]]; then
			OPT_T=$OPTARG 
		else	
			echo "${C_RED}${C_BOLD}-f $OPTARG invalid${C_NORM}"
			HELP
		fi
      	;;
		
    m)
		if [[ "$MODES" =~ "$TEST" ]]; then
			OPT_M=$OPTARG 
		else	
			echo "${C_RED}${C_BOLD}-f $OPTARG invalid${C_NORM}"
			HELP
		fi
      	;;

    h)  #show help
      	HELP
      	;;
    \?) #unrecognized option - show help
      	echo -e \\n"${C_RED}Option -${C_BOLD}$OPTARG${C_NORM}${C_RED} not allowed.${C_NORM}"
      	HELP
      	;;
  esac
done
debug "at shift" 1
shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

### End getopts code ###
debug "done shift" 1







# if [ "$BOARDTYPE" = "Relay" ]
#   then
# 	Top_Color=$1
# 	Top_Mode=$2
# 	[[ $MODES =~ $Top_Mode ]] || Top_Mode="none"
# 	Front_Color="nochange"
# 	Front_mode="nochange"
# 	if [ -z $1 ]
# 	then
#     	echo -e $errormsg1;
#     	exit;
# 	fi
# else
# 	#future, figure out what to do with a two LED system here.
# 	Top_Color=$1		
# 	Top_Mode=$2
# 	Front_Color=$3
# fi




function setcolor() {
	debug "setcolor(r=$1,g=$2,b=$3,rm=$4,gm=$5,bm=$6,type=$7)" 2
	r=$1
	g=$2
	b=$3
	rm=$4
	gm=$5
	bm=$6
	type=$7
	if [ "$type" = "front" ]
	then
	   	echo $r 	> $FrontRed/brightness
	    echo $rm 	> $FrontRed/trigger
	    echo $g 	> $FrontGreen/brightness
	    echo $gm	> $FrontGreen/trigger
	    echo $b 	> $FrontBlue/brightness
		echo $bm	> $FrontBlue/trigger
	else
	    echo $r 	> $TopRed/brightness
	    echo $rm 	> $TopRed/trigger
	    echo $g 	> $TopGreen/brightness
	    echo $gm	> $TopGreen/trigger
	    echo $b 	> $TopBlue/brightness
		echo $bm	> $TopBlue/trigger
		echo "last $TopBlue/trigger"
	fi
}


function color_assignment() {
	debug "color_assignemnt(Color=$1,mode=$2,Location=$3)" 1
	Color=$1
	m=$2
	LED_RAY=$3
    case "$Color" in
	'red')
	    setcolor 1 0 0 $m "none" "none" $LED_RAY
	    ;;
	'green')
	    setcolor 0 1 0 "none" $m "none" $LED_RAY
	    ;;
	'blue')
	    setcolor 0 0 1 "none" "none" $m $LED_RAY
	    ;;
	'yellow')
	    setcolor 1 1 0 $m $m "none" $LED_RAY
	    ;;
	'magenta')
	    setcolor 1 0 1 $m "none" $m $LED_RAY
	    ;;
	'cyan')
	    setcolor 0 1 1 "none" $m $m $LED_RAY
	    ;;
	'white')
	    setcolor 1 1 1 $m $m $m $LED_RAY
	    ;;
	'black')
	    setcolor 0 0 0 "none" "none" "none" $LED_RAY
	    ;;
	'off')
	    setcolor 0 0 0 "none" "none" "none" $LED_RAY
	    ;;
	'nochange')
	;;
    esac
}



function main() {
while [ $# -ne 0 ]; do
	if [[ "$COLORS" =~ "$1" ]]
	then 
		ALLCOLOR=$1
		single_color=1
	else	
		HELP 
	fi
	 shift  #Move on to next input file.
done
if [ "$single_color" = "1" ]; then
	if [ "$BOARDTYPE" = "Relay" ]; then
		OPT_T=$ALLCOLOR
		OPT_F="nochange"
	else
		OPT_F=$ALLCOLOR
		OPT_T=$ALLCOLOR
	fi
fi
if [ $OPT_M = "TEST" ]; then
	color_assignment "red" "none" "top"
	sleep 1
	color_assignment "green" "none" "top"
	sleep 1
	color_assignment "blue" "none" "top"
	sleep 1
	color_assignment "yellow" "none" "top"
	sleep 1
	color_assignment "cyan" "none" "top"
	sleep 1
	color_assignment "magenta" "none" "top"
	sleep 1
	color_assignment "white" "none" "top"
	sleep 1
	color_assignment "black" "none" "top"
else	
	color_assignment $OPT_F $OPT_M "front"
	color_assignment $OPT_T $OPT_M "top"
fi
}


#turn off the red "I have been powered led"
echo 1 > $RED_OFF/value
#pass main the remaining command line args
main $@


