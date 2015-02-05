
# source this file.
# Common code

# source this for common functions...
# make sure you use bash - not the default, which is ash on some systems. So so so annoying.

#Debug levels
#0 off
#1 screen
debug_level=0


COLOR_BOLD="echo -ne '\E[1m'"
COLOR_RED="echo -ne '\E[31m'"
COLOR_MAGENTA="echo -ne '\E[35m'"
COLOR_YELLOW="echo -ne '\E[33m'"
COLOR_GREEN="echo -ne '\E[32m'"
COLOR_NORMAL="echo -ne '\E[0m'"

### common vars

FRZ_MANIFEST_LST="manifest.lst"
FRZ_EXPAND_CFG="prereq-setup.cfg"

function setup_colors() {
	# OLDER color definitions
	SYSTYPE="$(eval "uname | cut -c 1-4")"
	case "$SYSTYPE" in 
    	Darw)
			COLOR_BOLD="echo -ne '\033[1m'"
			COLOR_RED="echo -ne '\033[31m'"
			COLOR_MAGENTA="echo -ne '\033[35m'"
			COLOR_YELLOW="echo -ne '\033[33m'"
			COLOR_GREEN="echo -ne '\033[32m'"
			COLOR_NORMAL="echo -ne '\033[0m'"
			;;
    	Linu|CYGW)   		
			COLOR_BOLD="echo -ne '\E[1m'"
			COLOR_RED="echo -ne '\E[31m'"
			COLOR_MAGENTA="echo -ne '\E[35m'"
			COLOR_YELLOW="echo -ne '\E[33m'"
			COLOR_GREEN="echo -ne '\E[32m'"
			COLOR_NORMAL="echo -ne '\E[0m'"
			;;
	esac
	#newer color definitions
	C_BLACK=`tput setaf 0`
	C_RED=`tput setaf 1`
	C_GREEN=`tput setaf 2`
	C_YELLOW=`tput setaf 3`
	C_BLUE=`tput setaf 4`
	C_MAGENTA=`tput setaf 5`
	C_CYAN=`tput setaf 6`
	C_WHITE=`tput setaf 7`
	#background
	C_BLACK_BG=`tput setab 0`
	C_RED_BG=`tput setab 1`
	C_GREEN_BG=`tput setab 2`
	C_YELLOW_BG=`tput setab 3`
	C_BLUE_BG=`tput setab 4`
	C_MAGENTA_BG=`tput setab 5`
	C_CYAN_BG=`tput setab 6`
	C_WHITE_BG=`tput setab 7`
	C_DIM=`tput dim`
	C_NORM=`tput sgr0`
	C_BOLD=`tput bold`
	C_REV=`tput smso`
	C_UND=`tput smul`
	#useage: echo -e "${C_RED} say stuff ${C_NORM}"
}

function debug() {
	string="$1"
	tablevel="$2"
	tabspace=""
	if [ "$debug_level" = "1" ]; then
		case $tablevel in
			1)
				C="${C_BLUE}";echo -e "$C DEBUG${C_NORM}";;
			2) C="${C_CYAN}"; tabspace="$tabsapce\t";;
			3) C="${C_YELLOW}"; tabspace="$tabsapce\t\t";;
		esac
		echo -e " $tabspace$C$string${C_NORM}"
	fi
}

#validates user input for a value match in a list
function validate_in_list() {
 	if [[ ! $2 =~ $1 ]]; then
 		echo "${C_RED}Error: ${C_NORM} $3 is invalid: ${C_MAGENTA}$1${C_NORM} is not a member of ${C_MAGENTA}[${2// /|}]${C_NORM}"
 		exit 0
 	fi
}
function validate_file_exists() {
 	if [[ ! -e $1 ]]; then
 		echo "${C_RED}Error: ${C_NORM} File ${C_MAGENTA}$1${C_NORM} does not exist."
 		exit 0
 	fi
}
# Use like this:
# 
# THISDIR=$(getScriptDir "${BASH_SOURCE[0]}")
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


function onexit() {
    local exit_status=${1:-$?}
    eval $COLOR_RED
    if [ $# -gt 1 ]; then
        echo "Error - $0 did not complete. $2"
    else
	echo "Error - $0 did not complete."
    fi	
    eval $COLOR_NORMAL
#    rm -f *.tmp
    exit $exit_status
}

function onerror() {
    eval $COLOR_RED
    echo "Error..."
    eval $COLOR_YELLOW
    echo "$@"
    eval $COLOR_NORMAL
#    rm -f *.tmp
    exit 1
}

function bold_echo() {
    eval $COLOR_BOLD
    echo "$@"
    eval $COLOR_NORMAL
}

function mkdir_inform() {
    for D in "$@"
    do
	if [ ! -d "$D" ]; then
	    eval $COLOR_BOLD 
	    echo "Creating directory: $D"
	    eval $COLOR_NORMAL
	    mkdir -p "$D"
	fi
    done
}

# takes $1 as where no softlink will be, $2 is the source
# directory location of the files and $3+ 
# is all the files who need softlinks in this directory
# these relative filename to $2
# this will also get rid of broken links
function mklinkdir_inform() {
    if [ ! -d "$1" ]; then
	eval $COLOR_RED
	echo "mksoftlinkfiles_inform: No dest $1 directory"
	eval $COLOR_NORMAL
	exit 1
    fi

    pushd "$1"

    shift

    if [ ! -d "$1" ]; then
	eval $COLOR_RED
	echo "mksoftlinkfiles_inform: No src $1 directory"
	eval $COLOR_NORMAL
	popd
	exit 1
    else
	SRCDIR="$1"
    fi
    
    shift



    for D in "$@"
    do
	F=`basename $D`
	SRCF="$SRCDIR"/"$F"
	if [ ! -e "$F" ]; then
	    eval $COLOR_BOLD 
	    echo "linking dir: $F"
	    eval $COLOR_NORMAL
	    ln -s "$SRCF" .
	fi

    done

    popd

}



# takes $1 as where no softlink will be, $2 is the source
# directory location of the files and $3+ 
# is all the files who need softlinks in this directory
# these relative filename to $2
# this will also get rid of broken links
function mksoftlinkfiles_inform() {
    if [ ! -d "$1" ]; then
	eval $COLOR_RED
	echo "mksoftlinkfiles_inform: No dest $1 directory"
	eval $COLOR_NORMAL
	exit 1
    fi

    pushd "$1"

    shift

    if [ ! -d "$1" ]; then
	eval $COLOR_RED
	echo "mksoftlinkfiles_inform: No src $1 directory"
	eval $COLOR_NORMAL
	popd
	exit 1
    else
	SRCDIR="$1"
    fi
    
    shift

    # remove broken links
    for D in *
    do
	if [ ! -e "$D" ]; then
	    eval $COLOR_YELLOW
	    echo "removing link $D"
	    eval $COLOR_NORMAL
	    rm -f "$D"
	fi
    done

    for D in "$@"
    do
	F=`basename $D`
	SRCF="$SRCDIR"/"$F"
	if [ ! -e "$F" ]; then
	    eval $COLOR_BOLD 
	    echo "linking file: $F"
	    eval $COLOR_NORMAL
	    ln -s "$SRCF" .
	fi
    done

    popd
}

setup_colors



