#!/bin/bash
COMMAND=$1

#----------------------------CONFIG-----------------------------
#SOFTLINKS
#format (linkpath1 linktarget1 linkpath2 linktarget2 ...)
#hardfloat detect: http://stackoverflow.com/questions/20555594/how-can-i-know-if-an-arm-library-is-using-hardfp
declare -a links=("/usr/bin/gcc" "/usr/bin/arm-poky-linux-gnueabi-gcc" "/usr/bin/cc" "/usr/bin/arm-poky-linux-gnueabi-gcc" "/usr/bin/g++" "/usr/bin/arm-poky-linux-gnueabi-g++" "/usr/bin/cpp" "/usr/bin/arm-poky-linux-gnueabi-cpp")



#-----------------------------Utils-------------------------

function report_title(){
echo -e "\n$1\n----------------------------------------------------------------------------------------------------------------------------"
}


function gettabs () {
  count=$1
  #echo "[$count]"
  if [ "$count" -ge 0 -a "$count" -le 7 ];   then out="\t\t\t\t\t\t\t\t\t\t";
elif [ "$count" -ge 8  -a "$count" -le 15 ]; then out="\t\t\t\t\t\t\t\t\t";
elif [ "$count" -ge 16 -a "$count" -le 23 ]; then out="\t\t\t\t\t\t\t\t";
elif [ "$count" -ge 24 -a "$count" -le 31 ]; then out="\t\t\t\t\t\t\t"; 
elif [ "$count" -ge 32 -a "$count" -le 39 ]; then out="\t\t\t\t\t\t";
elif [ "$count" -ge 40 -a "$count" -le 48 ]; then out="\t\t\t\t\t";
elif [ "$count" -ge 49 -a "$count" -le 56 ]; then out="\t\t\t\t";
elif [ "$count" -ge 57 -a "$count" -le 64 ]; then out="\t\t\t";
elif [ "$count" -ge 65 -a "$count" -le 72 ]; then out="\t\t";
elif [ "$count" -ge 73 -a "$count" -le 81 ]; then out="\t";
fi
  echo $out
}



function report(){
  testing=$1
  result=$2
  after=$3
  if [[ $result == 2 ]]; then
  line="${C_YELLOW}REPAIRED${C_NORM}"
  elif [[ $result == 1 ]]; then
  line="${C_GREEN}PASS${C_NORM}"
  else 
line="${C_RED}FAIL${C_NORM}"
  fi
  count=${#testing}
 # echo "$testing $count"
  out=$(gettabs $count)
echo -e "TESTING $testing$out$line\t\t$after"
}


function report_spinner_p1(){
testing=$1
pid=$2
spin[0]="-"
spin[1]="\\"
spin[2]="|"
spin[3]="/"
 count=${#testing}
  #echo "$testing $count"
  out=$(gettabs $count)
echo -n -e "Testing $testing$out${spin[0]}"
while kill -0 $pid 2>/dev/null
do
  for i in "${spin[@]}"
  do
        echo -ne "\b$i"
        sleep 0.1
  done
done
echo -ne "\b"
}

function report_spinner_p2(){
  result=$1
  after=$2
    if [[ $result != 1 ]]; then
  line="${C_RED}FAIL${C_NORM}"
  else  
  line="${C_GREEN}PASS${C_NORM}"
  fi
  echo -e "$line\t\t$after"
}



function status(){
  position1=$1
  position2=$2
  posistion3=$3

  out="\t"$(gettabs ${#position1})
  echo -e "$position1$out$position2\t\t$posistion3"
}



#------------------------------------Tests---------------------------------






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
. $THISDIR/../../common/common.sh

function add-softlink (){
  newname=$2
  target=$1
  ln -s $1 $2
}


function fixProcessorSpeed () {
  echo "Fixing CPU Speed"
  speed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
  echo -e "\tcurrent frequency speed:\t\t\t\t\t\t$speed"
  cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
  speed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
  echo -e "\tnew frequency speed:\t\t\t\t\t\t\t$speed"
}

function buildlinks () {
  report_title "Checking gcc softlinks"
  raylength="${#links[@]}"
  for i in $(seq 0 2 $((raylength-1))) 
  do 
  link="${links[i]}"
  link_target="${links[$((i+1))]}"
  if [[ ! -f $link ]]; then
    report "$link-->$link_target" 0 
    add-softlink $link_target $link
 link2="${links[i]}"
  link_target2="${links[$((i+1))]}"
  if [[ ! -f $link2 ]]; then
    report "repair of $link2-->$link_target2" 0 
  else
    report "repair of $link2-->$link_target2" 1
  fi
  else
     report "$link-->$link_target" 1
  fi
done
}

function tattle-etherent-cable(){
  report_title "testing ethernet connection stability"
GWIP=$(/sbin/ip route | awk '/default/ { print $3 }')

#ping -f -s 500 -i 10000 $GWIP
#packet_loss=$(ping -c 10000 -f -s 500 -q $GWIP | awk '/loss/ {print $6 }') 
$(ping -c 10000 -f -s 500 -q $GWIP | awk '/loss/ {print $6 }'>.out) &
pid=$! # Process Id of the previous running command
report_spinner_p1 "ping -f -s 500 -c 10000 $GWIP" $pid
packet_loss=`cat .out`
if [[ $packet_loss = "0%" ]]; then
report_spinner_p2  1 "$packet_loss packet loss"
else 
report_spinner_p2  0 "$packet_loss packet loss"
fi  
}


function tattle-memory(){
  report_title "testing memory chip stability"
$(memtester 5 1 > .out2 2>&1) &
pid=$!
report_spinner_p1 "5MB light weight memory test (60 seconds)" $pid
result=`cat .out2 | grep FAILURE`
if [[ $result != "" ]]; then
  report_spinner_p2 0
else
  report_spinner_p2 1
fi
}

function tester(){
  report_title "testing tab system"
report "1234567" 0
report "12345678" 0
report "123456789" 0
report "123456781234567" 0
report "1234567812345678" 0
report "12345678123456789" 0

echo -ne '#####                     (33%)\r'
sleep .1
echo -ne '#############             (66%)\r'
sleep .1
echo -ne '#######################   (100%)\r'
echo -ne '\n'

LIST="1 2 3 4 5"

MAXPROG=$(echo ${LIST} | wc -w)

for NUMBER in ${LIST};
do
 echo -n "$((${NUMBER}*100/${MAXPROG})) %     "
 echo -n R | tr 'R' '\r'
 sleep .1
done




}


function tattle_kernel(){
  report_title "Kernel Configs"
  config_SUNX=`zcat /proc/config.gz | grep SUNX`
  config_SUN4=`zcat /proc/config.gz | grep SUN4`
  config_SUN5=`zcat /proc/config.gz | grep SUN5`
  config_SUN6=`zcat /proc/config.gz | grep SUN6`
  config_SUN7=`zcat /proc/config.gz | grep SUN7`
  config_SUN8=`zcat /proc/config.gz | grep SUN8`
  config_SUN9=`zcat /proc/config.gz | grep SUN9`
  for cfg in "$config_SUNX" "$config_SUN4" "$config_SUN5" "$config_SUN6" "$config_SUN7" "$config_SUN8" "$config_SUN9"; do
    readarray -t myarray <<<"$cfg"
    for dir in "${myarray[@]}"; do
      pass=0  
      if [[ $dir == *"=y" ]]; then
        pass=1
      fi
      report "(SUNX)\t$dir" $pass
    done
  done

}

function tattle_kernelold(){
  report_title "Kernel Configs"
  config_GPIO=`zcat /proc/config.gz | grep CONFIG_GPIO_SUNXI`
  config_LEDS=`zcat /proc/config.gz | grep CONFIG_LEDS_SUNXI`
  config_8250=`zcat /proc/config.gz | grep CONFIG_SERIAL_8250_SUNXI`
  pass=1
  if [[ $config_GPIO != *"=y" ]]; then
    pass=0
  fi
    report "KERNEL CONFIG GPIO_SUNXI SET Y:" $pass $config_GPIO
pass=1
  if [[ $config_LEDS != *"=y" ]]; then
    pass=0
  fi
    report "KERNEL CONFIG LEDS_SUNXI SET Y:" $pass $config_LEDS
pass=1
  if [[ $config_8250 != *"=y" ]]; then
    pass=0
  fi
    report "KERNEL CONFIG SERIAL_8250_SUNXI SET Y:" $pass $config_8250
}

function tattle_processorspeed(){
report_title "CPU Speeds"

#CPU0
  cpu0_speed_min=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq`
  if [[ $cpu0_speed_min != "912000" ]]; then
    report "CPU0 minimum speed set to 912000" 0 "($cpu0_speed_min)"
    echo 912000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
 cpu0_speed_min=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq`
 if [[ $cpu0_speed_min == "912000" ]]; then
    report "CPU0 minimum speed repaire attempt to 912000" 1 "($cpu0_speed_min)"
  else
     report "CPU0 minimum speed repaire attempt to 912000" 0 "($cpu0_speed_min)"
fi
else
  report "CPU0 minimum speed set to 912000" 1 "($cpu0_speed_min)"
fi


cpu1_speed_min=`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq`
  if [[ $cpu1_speed_min != "912000" ]]; then
    report "CPU1 minimum speed set to 912000" 0 "($cpu1_speed_min)"
    echo 912000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
 cpu1_speed_min=`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq`
  if [[ $cpu1_speed_min == "912000" ]]; then
    report "CPU1 minimum speed repaire attempt to 912000" 1 "($cpu1_speed_min)"
  else
     report "CPU1 minimum speed repaire attempt to 912000" 0 "($cpu1_speed_min)"
fi
else
  report "CPU1 minimum speed set to 912000" 1 "($cpu1_speed_min)"
fi


}

function status_cpu_speeds() {

    report_title "CPU Speed Status Report"
    status "CPU0 minimum speed set to" "`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq`"
    status "CPU0 maximum speed set to" "`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq`"
    status "CPU0 current speed set to" "`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`"
    status "CPU1 minimum speed set to" "`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq`"
    status "CPU1 maximum speed set to" "`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq`"
    status "CPU1 current speed set to" "`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq`"

}


function status_uarts() {
report_title "UART Setup"

 for arg in 2 3 4 5 6 7
 do
  outmsg=""
   cmd="stty -F /dev/ttyS$arg raw speed 115200 -parenb -parodd cs8 hupcl -cstopb cread clocal -crtscts -ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr icrnl ixon -ixoff -iuclc -ixany -imaxbel -iutf8 -opost -olcuc -ocrnl onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 -isig -icanon iexten -echo -echoe echok -echonl -noflsh -xcase -tostop -echoprt echoctl echoke"
   baud=`$cmd`
   pass=1
   if [[ $baud != "115200" ]]; then
    baud=`$cmd`
    pass=2
    if [[ $baud != "115200" ]]; then
      pass=0
      outmesg="$baud"
    fi
  fi
  report "Setting /dev/ttyS$arg" $pass $outmesg
done


}

function status_uarts_old() {
 report_title "UART Assignment Status"

 for arg in 0 1 2 3 4 5 6 7
 do
 if [ -d "/sys/devices/platform/sunxi-uart.$arg/tty/" ]; then
  status "UART$arg\tAssigned:" "/dev/`ls /sys/devices/platform/sunxi-uart.$arg/tty/`"
else
  status "UART$arg\tUnssigned" "-" ""
fi
done
}


function tattle(){
   clear
  buildlinks
    tattle_kernel
  tattle_processorspeed
  tattle-etherent-cable
  tattle-memory
}

function main () {
  tattle
  status_uarts
  status_cpu_speeds

  tester

}

main
