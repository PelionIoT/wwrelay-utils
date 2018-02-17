#!/bin/bash
# /etc/init.d/sqa: starts an sqa test suite, that is configured here.  Normally, start does nothing.

### BEGIN INIT INFO
# Provides:             sqa
# Required-Start:       wwrelay
# Required-Stop:        
# Should-Start:         network
# Should-Stop:          
# Default-Start:        5
# Default-Stop:         0 1 6
# Short-Description:    remote terminal for the relay through cloud
### END INIT INFO


#initscripts need to be made aware of the path

#You can receive messages via papertrail, on the status of the SQA test. To enable, you must fill out the follwoing three varribles
USEPAPERTRAIL=0				#1 Enables, 0 Disables
PAPERPORT=					#the port for your papertrail account
PAPERHOST="YASHDESK"			#the name of the host machine running this test (e.g. your relay id or some location)
PAPERPROGRAM="SQA"				#the program tag (you can filter on this in papertrail)


#------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------SETUP-------------------------------------------------------------
##------------------------------------------------------------------------------------------------------------------------------
#SQA programs available
#-------------
#In order to run these loop tests, you must enable them with a 1
#Note: These test are only designed to be run 1 per relay, so only enable 1

#OOM_ is our out of memory loop test.  This forces an out of memory event on the system after X time.
DO_OOM=0;						#1 Enables, 0 Disables
OOM_STARTTIME=180;   			#ammount of time to wait in seconds before starting the OOM after each boot

#PANIC_ is our panic loop test.  Basically the program boots then panics after the PANIC_STARTTIME. The propose of this test is to test how the hardware reacts to a kernel panic
DO_PANIC=0;	  				#1 Enables, 0 Disables
PANIC_STARTTIME=180;				#Amount of time to wait in seconds before starting the PANIC after each boot. Less than 30 will result in you having to use recovery mode to stop it, because it will panic before login even happens over serial

#UPGRADE_ is our upgrade loop test.  Basically the program boots then upgrades the system with the command 'upgrade -r $UPGRADE_BNUM' after the UPGRADE_STARTTIME has expired. The propose of this test is to test how the hardware reacts to a upgrade (which is ending with an intional panic)
DO_UPGRADE=0;					#make sure to set: UPGRADE_STARTTIME
UPGRADE_STARTTIME=180;			#Amount of time to wait in seconds before starting the upgrade, 180 recommended to avoid a race with devicejs get IP
UPGRADE_BNUM="1.1.874"			#Build number to upgrade -r to...


DO_IPRIP=0;  					#1 Enables, 0 Disables
IPRIP_IP="";		 			#Static IP to switch to
IPRIP_NETMASK="";				#Static Netmask to fall to
IPRIP_BROADCAST="";				#Static broadcast to fall to
IPRIP_GW="";					#Static GW to fall to
IPRIP_TOGGLETIME=30;			#Time to flip flop from DHCP to Statc

DO_FACTORY=0;					#1 Enables, 0 Disables
FACTORY_MACHINE=RP200			#Set the machine you want to test, supports RP200 so far
#-------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------END-SETUP---------------------------------------------------------
##------------------------------------------------------------------------------------------------------------------------------



# Source function library.
source /etc/init.d/functions
PATH=$PATH:/wigwag/system/bin/:/wigwag/system/lib/

WIGWAGROOT="/wigwag"
WIGWAGLOGROOT="/wigwag/log"
PIDROOT="/var/run"
SQAROOT=$WIGWAGROOT"/wwrelay-utils/dev-tools/SQA"
SQA_LOG=$WIGWAGLOGROOT"/sqa.log"
SQA_PIDFILE=$PIDROOT"/sqa.pid"
SQA_CNT=$WIGWAGLOGROOT"/sqa.cnt"

#NOTE to future Test writters...
#1. the _PROG is an external program that is called from this script, and they all can be found in $SQAROOT.  If you want add a program, copy this paradigm.  If you want to modify an existing loop test, look to modify the _PROG first.
#2. the _PROG must be 1 word no space.  This is required to identify the PID
#3. Try to just keep logging to the SQA_LOG unless you need a different file for some reason.  Anything you throw to echo is captured in the log file, from the _PROG

FACTORY_PROG="start.sh"
FACTORY_PATH=$SQAROOT"/RP200/"$FACTORY_PROG
FACTORY_LOG=$SQA_LOG
FACTORY_CNT=$SQA_CNT
FACTORY_START="$FACTORY_PATH "
FACTORY_PIDFILE=$SQA_PIDFILE

#OOM_ Out of Memory test (other settings)
OOM_PROG="nodefiller.sh"
OOM_PATH=$SQAROOT"/"$OOM_PROG
OOM_LOG=$SQA_LOG
OOM_CNT=$SQA_CNT
OOM_START="$OOM_PATH "
OOM_PIDFILE=$SQA_PIDFILE

#PANIC_ Out of Memory test (other settings)
PANIC_PROG="panic.sh"
PANIC_PATH=$SQAROOT"/"$PANIC_PROG
PANIC_LOG=$SQA_LOG
PANIC_CNT=$SQA_CNT
PANIC_START="$PANIC_PATH $PANIC_STARTTIME"
PANIC_PIDFILE=$SQA_PIDFILE

#UPGRADE LOOP TEST (Other settings)
UPGRADE_PROG="upgradeloop.sh"
UPGRADE_PATH=$SQAROOT"/"$UPGRADE_PROG
UPGRADE_LOG=$SQA_LOG
UPGRADE_CNT=$SQA_CNT
UPGRADE_START="$UPGRADE_PATH $UPGRADE_STARTTIME $UPGRADE_BNUM"
UPGRADE_PIDFILE=$SQA_PIDFILE


#IPRIP_ (other settings)
IPRIP_PROG="IPRIP.sh"
IPRIP_PATH=$SQAROOT"/"$IPRIP_PROG
IPRIP_LOG=$SQA_LOG
IPRIP_CNT=$SQA_CNT
IPRIP_START="$IPRIP_PATH $IPRIP_IP $IPRIP_NETMASK $IPRIP_BROADCAST $IPRIP_GW $IPRIP_TOGGLETIME"
IPRIP_PIDFILE=$SQA_PIDFILE


_log() {
	local logtopapertraildo=0;
	echo -e "$1: $2" >> $SQA_LOG
	echo -e "$2"
	if [[ logtopapertraildo -eq 1 ]]; then
		logitp "$2"
	fi
}


logitPapertrailDetail() {
	host="$1"
	program="$2"
	message="$3"
	mdate=$(date +"%Y-%m-%dT%H:%M:%SZ")
	mdate="2014-06-18T09:56:21Z"
	echo -e "<22>1 $mdate $1 $2 - - - $3" | nc logs4.papertrailapp.com $PAPERPORT
} #end_logitPapertrailDetail

logitp(){
	if [[ $USEPAPERTRAIL -eq 1 ]]; then
		udhcpc -n
		logitPapertrailDetail "$PAPERHOST" "$PAPERPROGRAM" "$1"
	fi
} #end_logitp


## Check to see if we are running as root first.
if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

_start(){
	LOG="$1"
	PROG="$2"
	PIDFILE="$3"
	START="$4"
	cnt="$5"
	if [[ ! -e $LOG ]]; then
		touch $LOG
	fi
	chmod 777 $LOG
	c=$(pgrep -f $PROG | wc -l)
	if [[ $c -gt 1 ]]; then  
		error
		echo " Error! $c $PROG processes found.  Must fix this.  try killAll" 1>&2
		logitp "SQA initscript could not find $PROG"
	elif [[ $c -eq 1 ]]; then
		pid=$(cat $PIDFILE);
		warning
		_log "SQA" " Warning! $PROG is currently running! ($pid)" 1>&2
	else
        ## Change from /dev/null to something like /var/log/$PROG if you want to save output.
        _log "SQA" "my pgrep: -f $PROG"
        _log "SQA" "startline: $START >> $LOG 2>&1 &"
        eval "$START >> $LOG 2>&1 &"
        #sudo su -c "/usr/bin/node $RELAYTERM start $RELAYTERMCONF > $RELAYTERM_LOG 2>&1 &" -s /bin/bash wigwaguser
        pid=$(pgrep -f $PROG)
        echo "$pid">"$PIDFILE"
        success
        echo " Started $PROG ($pid)"
        if [[ "$cnt" != "" ]]; then
        	num=$(cat $cnt);num=$(( $num + 1 ));echo "$num" > "$cnt"
        fi
        logitp "Started number: $num"
   fi
}

_stop() {
	PIDFILE="$1"
	if [ -e "$PIDFILE" ]; then
        ## Program is running, so stop it
        pid=`cat $PIDFILE`
        kill -9 $pid
        rm "$PIDFILE"
        success
        _log "SQA" " $PROG stopped ($pid)"
   else
        ## Program is not running, exit with error.
        warning
        _log "SQA" " Warning! $PROG not started!" 1>&2
        exit 1
   fi
}

_status(){
	LOG="$1"
	PROG="$2"
	PIDFILE="$3"
	cnt="$4"
	#echo -en "$1\n$2\n$3\n$4\n"
	#exit
	if [[ -e $PIDFILE ]]; then
		pid=`cat $PIDFILE`
		if [[ $cnt != "" ]]; then
			num=$(cat $cnt);
			STR="$PROG (pid $pid) is running... Logging to $LOG. Current count=$num"
		else
			STR="$PROG (pid $pid) is running... Logging to $LOG.";
		fi
		echo "$STR"
		#echo "$STR >/dev/ttyS0"
	else
		echo "$PROG not running."
	fi
}

_displayDOs(){
	_log "SQA.sh" " DO_OOM:\t$DO_OOM"
	_log "SQA.sh" " DO_PANIC:\t$DO_PANIC"
	_log "SQA.sh" " DO_IPRIP:\t$DO_IPRIP"
	_log "SQA.sh" " DO_UPGRADE:\t$DO_UPGRADE"
	_log "SQA.sh" " DO_PIDFILE:\t$DO_PIDFILE"
	_log "SQA.sh" " DO_PROG:\t$DO_PROG"
	_log "SQA.sh" " DO_START:\t$DO_START"
	_log "SQA.sh" " DO_CNT:\t$DO_CNT"
	_log "SQA.sh" " DO_LOG:\t$DO_LOG"
	_log "SQA.sh" " DO_FACTORY:\t$DO_FACTORY"
}

_updatePAPERPROGRAM(){
	if [[ $PAPERPROGRAM != "" ]]; then
		PAPERPROGRAM="$PAPERPROGRAM[$1]"
	fi
}

killAll() {
	if [ -e "$PIDFILE" ]; then
        ## Program is running, so stop it
        pid=`cat $PIDFILE`
        kill -9 $pid
        if [[ $? -eq 0 ]]; then
        	success 
        	echo " $PROG stopped ($pid)"
        fi
        rm "$PIDFILE"
        if [[ $? -eq 0 ]]; then
        	success
        	echo " removed $PIDFILE"
        fi
   fi
   c=$(pgrep -f $PROG | wc -l)
    #c=$(($c - 2));
    #echo "my c=$c prog=$PROG"
    #pgrep -f $PROG
    #ps ax | grep $PROG
    if [[ $c -gt 0 ]]; then  

    	echo stopping $c rogue $PROG
    	pkill -f $PROG
    	if [[ $? ]]; then
    		success
    		echo " killed $c rogue $PROG"
    	fi
    else
    	success
    	echo " no extra $PROG processes found"
    fi
}

total=$(($DO_OOM+$DO_PANIC+$DO_IPRIP+$DO_UPGRADE+DO_FACTORY))
if [[ $total -gt 1 ]]; then
	error
	_log "SQA.sh" " Too much configured for /etc/init.d/sqa"
	_displayDOs
elif [[ $total -eq 0 ]]; then
	warning
	_displayDOs
elif [[ $DO_FACTORY -eq 1 ]]; then
	_updatePAPERPROGRAM FACTORY
	DO_LOG="$FACTORY_LOG"
	DO_PROG="$FACTORY_PROG"
	DO_PIDFILE="$FACTORY_PIDFILE"
	DO_START="$FACTORY_START"
	DO_CNT="$FACTORY_CNT"
elif [[ $DO_OOM -eq 1 ]]; then
	_updatePAPERPROGRAM OOM
	DO_LOG="$OOM_LOG"
	DO_PROG="$OOM_PROG"
	DO_PIDFILE="$OOM_PIDFILE"
	DO_START="$OOM_START"
	DO_CNT="$OOM_CNT"
elif [[ $DO_PANIC -eq 1 ]]; then
	_updatePAPERPROGRAM PANIC
	DO_LOG="$PANIC_LOG"
	DO_PROG="$PANIC_PROG"
	DO_PIDFILE="$PANIC_PIDFILE"
	DO_START="$PANIC_START"
	DO_CNT="$PANIC_CNT"
elif [[ $DO_IPRIP -eq 1 ]]; then
	_updatePAPERPROGRAM IPRIP
	DO_LOG="$IPRIP_LOG"
	DO_PROG="$IPRIP_PROG"
	DO_PIDFILE="$IPRIP_PIDFILE"
	DO_START="$IPRIP_START"
	DO_CNT="$IPRIP_CNT"
elif [[ $DO_UPGRADE -eq 1 ]]; then
	_updatePAPERPROGRAM UPGRADE
	DO_LOG="$UPGRADE_LOG"
	DO_PROG="$UPGRADE_PROG"
	DO_PIDFILE="$UPGRADE_PIDFILE"
	DO_START="$UPGRADE_START"
	DO_CNT="$UPGRADE_CNT"
fi


case "$1" in
	start) _start "$DO_LOG" "$DO_PROG" "$DO_PIDFILE" "$DO_START" "$DO_CNT"; exit 0; ;;
    		#
    		stop) _stop "$DO_PIDFILE"; exit 0; ;;
   		#
   		killAll) killAll; exit 0; ;;
    		#
    		status) _status "$DO_LOG" "$DO_PROG" "$DO_PIDFILE" "$DO_CNT"; exit 0; ;;
    		#
    		testpaper) logitp "A test\t message"; exit 0; ;;
    		#
    		reload|restart|force-reload) stop; start; exit 0; ;;
		#
		**) echo "Usage: $0 {start|stop|status|reload|killAll|testpaper}" 1>&2; exit 1; ;;
		#
	esac
fi