#!/bin/bash
COMMAND=$1

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

THISDIR=$(getScriptDir "${BASH_SOURCE[0]}")
. $THISDIR/../common/common.sh

# bring GPIO functions and the important varriables
. $THISDIR/../GPIO/setup-gpio.sh funcsonly
SCRIPT=`basename ${BASH_SOURCE[0]}`







#Check the number of arguments. If none are passed, print help and exit.
function checkargs(){
    NUMARGS=$1
    if [ $NUMARGS -eq 0 ]; then
        echo -e \\n"Number of arguments: $NUMARGS"
        HELP
    fi
}


#---------------------------------------------------------------------------------------------------------------------------------------------------
# Primary functions for the script
#
#---------------------------------------------------------------------------------------------------------------------------------------------------


function SET_PIN() {
    debug "SET_PIN(pin=$1,direction=$2)" 2
    pin=$1
    direction=$2
    if [ "$direction" = "High" ];then
        debug "echo 1 > $pin" 3
        echo 1 > $pin
    else
        debug "echo 0 > $pin" 3
        echo 0 > $pin
    fi
}

function 6Breset () {
    debug "6Breset()" 1
    SET_PIN "$SBMC_RESET/value" "Low"
    sleep $RESETTIME
    SET_PIN "$SBMC_RESET/value" "High"    
}

function 6Berase() {
    debug "6Berase()" 1
    SET_PIN "$SBMC_ERASE/value" "High"
    6Breset
    sleep 2
    SET_PIN "$SBMC_ERASE/value" "Low"
}

function 6BStatus() {
    echo "${C_BOLD}${C_UND}6BMC13224 Pin Status${C_NORM}"
    echo -e "\t${C_BOLD}UART:\t\t${C_GREEN} $tty${C_NORM}"
    echo -e "\t${C_BOLD}RTS PIN:\t${C_GREEN} $SBMC_RTS \t$(cat $SBMC_RTS/value)${C_NORM}"
    echo -e "\t${C_BOLD}ERASE PIN:\t${C_GREEN} $SBMC_ERASE \t$(cat $SBMC_ERASE/value)${C_NORM}"
    echo -e "\t${C_BOLD}RESET PIN:\t${C_GREEN} $SBMC_RESET \t$(cat $SBMC_RESET/value)${C_NORM}"
}

burnpid=""
function burn() {
    debug "burn($1)"
    echo -e "flashcmd: with $1\n"
    eval "$1" &
    burnpid=$!
}

function 6Bprogram() {
    debug "6Bprogram(file=$1)"
    echo -e "Programming the 6Bee\n"
    burnercmd="$Loader $v -t $tty -f $Flasher -s $1 -u $Baudrate -e -c '$THISDIR/6Bcontrol.sh -R'"
    ramburncmd="$THISDIR/$Loader $v -t $tty -f $1 -u $Baudrate"
    6Berase
    SET_PIN "$SBMC_RTS/value" "low"
    if [[ $Mode == "Romburn" ]]; then
        burn "$burnercmd"
    else
        burn "$ramburncmd"
    fi
    6Breset
    sleep 1
    wait $burnpid
    SET_PIN "$SBMC_RTS/value" "high"
}

function 6Buartsettings(){
    stty -F $tty raw speed 115200 -parenb -parodd cs8 -hupcl -cstopb cread clocal -crtscts -ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -iuclc -ixany -imaxbel -iutf8 -opost -olcuc -ocrnl onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 -isig -icanon -iexten -echo -echoe echok -echonl -noflsh -xcase -tostop -echoprt echoctl echoke
    #stty -F $tty raw speed 115200 -parenb -parodd cs8 -hupcl -cstopb cread clocal -crtscts ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -iuclc -ixany -imaxbel -iutf8 -opost -olcuc -ocrnl -onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 -isig -icanon -iexten -echo -echoe -echok -echonl -noflsh -xcase -tostop -echoprt -echoctl -echoke   
}

function Killallstuff() {
    killall tunslip6
    killall mc1322x-load
    killall mctest
}


function ramburn() {
    echo -e "Ramburn the 6Bee\n"
    6Berase
    setRTS 0
    burn "$ramburncmd"
    sleep 1
    wait $burnpid
    setRTS 1
}


#---------------------------------------------------------------------------------------------------------------------------------------------------
# Command line option parser
#
# big switch statement that processes all the command line arguments
#---------------------------------------------------------------------------------------------------------------------------------------------------
function process_args(){
    eval set -- "$PARSED_CLI"
    # extract options and their arguments into variables.
    # Only for educational purposes. Can be removed.
    #-----------------------------------------------
    debugcli=0
    if [[ $debugcli = 1 ]];then
        echo "++ Test: Number of arguments: [$#]"
        echo '++ Test: Looping through "$@:'$@'"'
        for a in "$@"; do
            echo "  ++ [$a]"
        done
    fi
    #-----------------------------------------------
    action=0;
    while true ; do
        case "$1" in
            -h|--Help) HELP ;;
            -S|--Status) 6BStatus ; shift ;;
            -c|--Configure) 6Buartsettings ; shift ;;
            -R|--Reset) 6Breset ; shift ;;
            -E|--Erase) 6Berase ; shift ;;
            -K|--Kill) Killallstuff ; shift ;;
            -v|--Verbose) v="-v" ; shift ;;
            -e|--ErasePin)
                case "$2" in
                    "") shift 2 ;;
                    *) validate_in_list $2 "$SETABLES" "-E --ErasePin"; SET_PIN "$SBMC_ERASE/value" "$2"; shift 2 ;;
                esac ;;
            -r|--ResetPin)
                case "$2" in
                    "") shift 2 ;;
                    *) validate_in_list $2 "$SETABLES" "-r --ResetPin";SET_PIN "$SBMC_RESET/value" "$2" ; shift 2 ;;
                esac ;;
            -u|--RTSPin)
                case "$2" in
                    "") shift 2 ;;
                    *) validate_in_list $2 "$SETABLES" "-S --RTSPin";SET_PIN "$SBMC_RTS/value" "$2" ; shift 2 ;;
                esac ;;
            -P|--Program)
                case "$2" in
                    "") shift 2 ;;
                    *)  validate_file_exists $2; Program="$2" ; shift 2 ;;
                esac ;;
            -b|--Baud)
                case "$2" in
                    "") shift 2 ;;
                    *) validate_in_list $2 "$BAUDS" "-B --Baud"; Baudrate=$2 ; shift 2 ;;
                esac ;;
            -f|--Flasher)
                case "$2" in
                    "") shift 2 ;;
                    *) validate_in_list $2 "$FLASHERS" "-f --Flasher";Flasher="$2" ; shift 2 ;;
                esac ;;
            -m|--Mode)
                case "$2" in
                    "") shift 2 ;;
                    *) validate_in_list $2 "$MODES" "-m --Mode";Mode="$2" ; shift 2 ;;
                esac ;;
            -t|--ttyPort)
                case "$2" in
                    "") shift 2 ;;
                    *) validate_file_exists $2;tty="$2" ; shift 2 ;;
                esac ;;
            -l|--Loader)
                case "$2" in
                    "") shift 2 ;;
                    *) validate_in_list $2 "$LOADERS" "-l --Loader";Loader="$2" ; shift 2 ;;
                esac ;;
            --) shift ; break ;;
            *) echo "Error $SCRIPT requires command line arguments"; HELP ;;
        esac
    done
}



#---------------------------------------------------------------------------------------------------------------------------------------------------
# Command line help
#
#---------------------------------------------------------------------------------------------------------------------------------------------------
function HELP {
    C=${C_GREEN}
    N=${C_NORM}
    echo -e \\n"${C_UND}${C_BOLD}Help documentation${C_UND} for ${SCRIPT}.${C_NORM}"
    echo -e "  Commands the 6BSMD_MC13224 (6BMC13)"
    echo -e "  Usage: $SCRIPT [OPTIONS] [PARAMATERS]"
    echo -e "${C_UND}Options:${C_NORM}"
    echo -e " -c, --Configure\tSets the default settings for the ttyPort"
    echo -e " -e, --ErasePin\t\t$C[${SETABLES// /|}]$N Sets erase pin. (Default: Low)"
    echo -e " -E, --Erase\t\tErases the 6BEE."
    echo -e " -h, --Help\t\tDisplays the help message."
    echo -e " -K, --Kill\t\tKill all 6BEE programs (Tunslip & programmers)."
    echo -e " -P, --Program\t\t$C<File>$N Programs the given file into the 6BMC13"
    echo -e "   -b, --Baud\t\t$C[${BAUDS// /|}]$N Sets baud rate. (Defualt: $Baudrate)"
    echo -e "   -l, --Loader\t\t$C[${LOADERS// /|}]$N Programer to use. (Default: $Loader)"
    echo -e "   -f, --Flasher\t$C[${FLASHERS// /|}]$N Flasher to use."
    echo -e "   -t, --ttyPort\t Sets the ttyPort.  (Default: $tty)"
    echo -e "   -v, --Verbose\tPass the flasher the -v argument (silent without v)."
    echo -e "   -m, --Mode\t\t$C[${MODES// /|}]$N Mode to use (Default: $Mode)"
    echo -e " -r, --ResetPin\t\t$C[${SETABLES// /|}]$N Sets reset pin. (Default: High)"
    echo -e " -R, --Reset\t\tToggles reset pin."
    echo -e " -S, --Status\t\tDisplays status for all pins."
    echo -e " -u, --RTSPin\t\t$C[${SETABLES// /|}]$N Sets RTS pin. (Default: Low)"
    echo -e "${C_UND}Examples:${C_NORM}"
    echo -e " $SCRIPT --Status\tPrints the status of each pin"
    echo -e " $SCRIPT --Program file\tPrograms the file into the 6BMC13224"\\n
  exit 1
}





#---------------------------------------------------------------------------------------------------------------------------------------------------
#Default varribles
#
# overwrite with command line switches
#---------------------------------------------------------------------------------------------------------------------------------------------------
Baudrate=115200
Loader=$THISDIR/mc1322x-load
Mode=Romburn
tty=$SBMC_TTY
Flasher=$THISDIR/flasher.bin
v=""
Program=""
RESETTIME=1



#---------------------------------------------------------------------------------------------------------------------------------------------------
# Acceptable parameters
#
# used in command line switches (these are checked against)
#---------------------------------------------------------------------------------------------------------------------------------------------------
BAUDS="115200 57600 19200 9600"
FLASHERS="flasher.bin flasher_m12.bin f2-econotag.bin"
LOADERS="mc1322x-load mctest"
SETABLES="High Low"
MODES="Ramburn Romburn"


#---------------------------------------------------------------------------------------------------------------------------------------------------
#MAIN
#We are using getopt to process args, a good article on this can be found here: http://www.bahmanm.com/blogs/command-line-options-how-to-parse-in-bash-using-getopt
#: required
#:: optional
#-o single char opt
#--long long declaration
#caputures the output of getopt, if error stops the script, dispays the error, and Help
#---------------------------------------------------------------------------------------------------------------------------------------------------
#checkargs $#

PARSED_CLI=`getopt -o e:u:r:b:l:f:m:t:vcSKERP:h --long ErasePin:,RTSPin:,ResetPin:,Baud:,Loader:,Flasher:,Mode:,ttyPort:,Configure,Verbose,Kill,Status,Erase,Reset,Program:,Help -n ${SCRIPT} -- "$@" 2> /tmp/errorfile`
if [[ $? = 1 ]]; then
    ERR=$(</tmp/errorfile)
    echo -e "${C_RED}Error: $ERR${C_NORM}"
    HELP
fi

process_args
if [[ "$Program" != "" ]]; then
    Killallstuff
    6Bprogram "$Program"
    6Breset
fi