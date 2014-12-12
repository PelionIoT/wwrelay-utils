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





# burner=$THISDIR/mc1322x-load
# burner=$THISDIR/mctest
# t=$SBMC_TTY
# #t=/dev/ttyUSB0
# #t=/dev/ttyS2
# #t=/dev/ttyS0
# #t=/dev/ttyUSB1
# f=$THISDIR/flasher_redbee-econotag.bin
# b=115200
# #burnercmd="$burner -t $t -f $f -b $b -s $2"

# ramburncmd="$burner -v -t $t -f $2 -u 115200 -e"



function SET_PIN() {
    debug "SET_PIN(pin=$1,direction=$2)" 2
    pin=$1
    direction=$2
    if [ "$direction" = "High" ];then
        debug "echo 1 > $pin" 3
        echo 1 > $pin
    else
        debug "echo 1 > $pin" 3
        echo 0 > $pin
    fi
}

function 6Breset () {
    debug "6Breset()" 1
    SET_PIN "$SBMC_RESET/value" "Low"
    sleep 1
    SET_PIN "$SBMC_RESET/value" "High"    
}

function 6Berase() {
    debug "6Berase()" 1
    SET_PIN "$SBMC_ERASE/value" "High"
    6Breset
    sleep 3
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
    echo -e "burning with $burnercmd\n"
    $1 &
    burnpid=$!
}

function 6Bprogram() {
    debug "6Bprogram(file=$1)"
    echo -e "Programming the 6Bee\n"
    burnercmd="$THISDIR/$Loader $v -t $tty -f $Flasher -s $1 -u 115200 -e"
    6Berase
    SET_PIN "$SBMC_RTS/value" "low"
    burn "$burnercmd"
    6Breset
    sleep 1
    wait $burnpid
    SET_PIN "$SBMC_RTS/value" "high"
}

function 6Buartsettings(){
    stty -F $tty raw speed 115200 -parenb -parodd cs8 -hupcl -cstopb cread clocal -crtscts -ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -iuclc -ixany -imaxbel -iutf8 -opost -olcuc -ocrnl onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 -isig -icanon -iexten -echo -echoe echok -echonl -noflsh -xcase -tostop -echoprt echoctl echoke
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



function process_args(){
    eval set -- "$PARSED_CLI"
    # extract options and their arguments into variables.
    # Only for educational purposes. Can be removed.
    #-----------------------------------------------
    # echo "++ Test: Number of arguments: [$#]"
    # echo '++ Test: Looping through "$@:'$@'"'
    # for a in "$@"; do
    #     echo "  ++ [$a]"
    # done
    #-----------------------------------------------
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
            -r|--RTSPin)
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
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done
}



#Help function
function HELP {
    C=${C_GREEN}
    N=${C_NORM}
    echo -e \\n"${C_UND}${C_BOLD}Help documentation${C_UND} for ${SCRIPT}.${C_NORM}"
    echo -e "  Commands the 6BSMD_MC13224 (6BMC13)"
    echo -e "  Usage: $SCRIPT [OPTIONS] [PARAMATERS]"
    echo -e "${C_UND}Options:${C_NORM}"
    echo -e " -c, --Configure\t Sets the default settings for the ttyPort"
    echo -e " -e, --ErasePin\t$C[${SETABLES// /|}]$N Sets erase pin. (Default: Low)"
    echo -e " -E, --Erase\tErases the 6BEE."
    echo -e " -h, --Help\tDisplays the help message."
    echo -e " -K, --Kill\tKill all 6BEE programs (Tunslip & programmers)."
    echo -e " -P, --Program\t$C<File>$N Programs the given file into the 6BMC13"
    echo -e "  -b, --Baud\t$C[${BAUDS// /|}]$N Sets baud rate. (Defualt: $Baudrate)"
    echo -e "  -l, --Loader\t$C[${LOADERS// /|}]$N Programer to use. (Default:$Loader)"
    echo -e "  -f, --Flasher\t$C[${FLASHERS// /|}]$N Flasher to use."
    echo -e "  -v, --Verbose\tPass the flasher the -v argument."
    echo -e " -r, --ResetPin\t$C[${SETABLES// /|}]$N Sets reset pin. (Default: High)"
    echo -e " -R, --Reset\tToggles the reset pin."
    echo -e " -S, --Status\tDisplays status for all pins."
    echo -e " -t, --ttyPort\t Sets the ttyPort.  (Default: $tty)"
    echo -e " -u, --RTSPin\t$C[${SETABLES// /|}]$N Sets RTS pin. (Default: Low)"
    echo -e "${C_UND}Examples:${C_NORM}"
    echo -e " $SCRIPT --Status \tPrints the status of each pin"
    echo -e " $SCRIPT --Program file \tPrograms the file into the 6BMC13224"\\n
  exit 1
}



#MAIN
#We are using getopt to process args, a good article on this can be found here: http://www.bahmanm.com/blogs/command-line-options-how-to-parse-in-bash-using-getopt
#: required
#:: optional
#-o single char opt
#--long long declaration

#Set our default varribles that can be overwritten with command line switches
Baudrate=115200
Loader=mc1322x-load
tty=$SBMC_TTY
Flasher=flasher.bin
v=""
Program=""

BAUDS="115200 57600 19200 9600"
FLASHERS="flasher.bin flasher_m12.bin f2-econotag.bin"
LOADERS="mc1322x-load mctest"
SETABLES="High Low"



checkargs $#

#caputures the output of getopt, if error stops the script, dispays the error, and Help
PARSED_CLI=`getopt -o e:u:r:b:l:f:t:vcSKERP:h --long ErasePin:,RTSPin:,ResetPin:,Baud:,Loader:,Flasher:,ttyPort:,Configure,Verbose,Kill,Status,Erase,Reset,Program:,Help -n ${SCRIPT} -- "$@" 2> /tmp/errorfile`
if [[ $? = 1 ]]; then
    ERR=$(</tmp/errorfile)
    echo -e "${C_RED}Error: $ERR${C_NORM}"
    HELP
fi

process_args
if [[ "$Program" != "" ]]; then
    6Bprogram "$Program"
fi