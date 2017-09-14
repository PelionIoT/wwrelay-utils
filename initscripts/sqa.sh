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
# Source function library.
source /etc/init.d/functions

WIGWAGROOT="/wigwag"
WIGWAGLOGROOT="/wigwag/log"
PIDROOT="/var/run"

SQAROOT=$WIGWAGROOT"/wwrelay-utils/devtools/sqa"
SQALOG=$WIGWAGLOGROOT"/sqa.log"

DO_OOM=0;
OOM_PATH=$SQAROOT"/nodefiller.sh"
OOM_LOG=$WIGWAGLOGROOT"/oom.log"
OOM_CNT=$WIGWAGLOGROOT"/oom.cnt"
OOM_START="/usr/bin/node $OOM_PATH &"
OOM_PIDFILE=$PIDROOT"/OOM.pid"


DO_PANIC=0


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
    elif [[ $c -eq 1 ]]; then
        pid=$(cat $PIDFILE);
        warning
        echo " Warning! $PROG is currently running! ($pid)" 1>&2
    else
        ## Change from /dev/null to something like /var/log/$PROG if you want to save output.
        #echo "my pgrep: -f $PROG"
        eval "$START > $LOG 2>&1 &"
        #sudo su -c "/usr/bin/node $RELAYTERM start $RELAYTERMCONF > $RELAYTERM_LOG 2>&1 &" -s /bin/bash wigwaguser
        pid=$(pgrep -f $PROG)
        echo "$pid">"$PIDFILE"
        success
        echo " Started $PROG ($pid)"
        if [[ "$cnt" != "" ]]; then
            num=$(cat $cnt);num=$(( $num + 1 ));echo "$num" > "$cnt"
        fi
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
        echo " $PROG stopped ($pid)"
    else
        ## Program is not running, exit with error.
        warning
        echo " Warning! $PROG not started!" 1>&2
        exit 1
    fi
}

_status(){
    LOG="$1"
    PROG="$2"
    PIDFILE="$3"
    cnt="$4"
    if [[ -e $PIDFILE ]]; then
        pid=`cat $PIDFILE`
        if [[ $cnt != "" ]]; then
            num=$(cat $cnt);
            STR="$PROG (pid $pid) is running... Logging to $LOG. Current count=$num"
        else
            STR="$PROG (pid $pid) is running... Logging to $LOG.";
        fi
        echo "$STR"
        echo "$STR >/dev/ttyS0"
    else
        echo "$PROG not running."
    fi
}

start_OOM() {
    _start "$OOM_LOG" "$OOM_PROG" "$OOM_PIDFILE" "$OOM_START" "$OOM_CNT"
}

stop_OOM(){
    _stop "$OOM_PIDFILE"
}

status_OOM(){
    _status "$OOM_LOG" "$OOM_PROG" "$OOM_PIDFILE" "$OOM_CNT"
}


status(){
  if [[ DO_OOM -eq 1 ]]; then
    status_OOM
elif [[ DO_PANIC -eq 1 ]]; then
    status_PANIC
else
    echo "Nothing for SQA to report for status" >> $SQALOG
fi
}

start(){
    if [[ DO_OOM -eq 1 ]]; then
        start_OOM
    elif [[ DO_PANIC -eq 1 ]]; then
        start_PANIC
    else
        echo "Nothing for SQA to start" >> $SQALOG
    fi
}

if [[ DO_OOM -eq 1 ]]; then
    stop_OOM
elif [[ DO_PANIC -eq 1 ]]; then
    stop_PANIC
else
    echo "Nothing for SQA to stop" >> $SQALOG
fi


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






case "$1" in
    start)
        #
        start
        exit 0
        ;;
    #
    stop)
        #
        stop
        exit 0
        ;;
    #
    killAll)
        #
        killAll
        exit 0
        ;;
    #
    status)
        #
        status
        exit 0
        ;;
    #
    reload|restart|force-reload)
        #
        stop
        start
        exit 0
        ;;
    #
    **)
        #
        echo "Usage: $0 {start|stop|status|reload|killAll}" 1>&2
        exit 1
        ;;
#
esac
