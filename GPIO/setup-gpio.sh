#!/bin/bash


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

GPIO_THISDIR=$(getScriptDir "${BASH_SOURCE[0]}")
. $GPIO_THISDIR/../common/common.sh


# . /etc/wigwag/relayconf.sh
# echo $hardware_gpioProfile_RED_OFF
# exit
#eval $COLOR_BOLD
#echo "Setting up WWRelay (rev 5) GPIO ports"
#eval $COLOR_NORMAL


### add here

#exit

#GPIODEF defines the layout for the board.  This will become useful when we produce other version.   
#Eventually we need a function here to read the CPU serial number to understand what boardtype it was deployed with
#BOARDTYPES

#v1 -contains A10 or A20 in a double stack, or singlestack
#v2 -contains A20 with Amplifier chips
#v2a -a temporary led fix, treating leds as gpios
#v3 -never produced
#v4 -contains A20 with Amplifier chips and fix for red led. (V2=v4 for this file)

#BOARDT
. /etc/wigwag/relayconf.sh
#theboardversion=$(cat /etc/wigwag/relay.conf | gawk -F'hardwareVersion": "' '{print $2}' | gawk -F'",' '{print $1}')
#echo -e "Board Factory Version:\t$theboardversion"
echo -e "The hardware version: \t$hardwareVersion"
theboardversion=$hardwareVersion
case $theboardversion in
  "0.0.1") GPIODEF="GPIO_V1";;
  "0.0.2") GPIODEF="GPIO_V2";;
  "0.0.4") GPIODEF="GPIO_V2";;
  "0.0.5") GPIODEF="GPIO_V5";;
  "0.0.6") GPIODEF="GPIO_V6";;
  *) GPIODEF="GPIO_V2";;
esac
echo -e "Board GPIO definition:\t$GPIODEF"


GPIOpath=/sys/class/gpio
LEDspath=/sys/class/leds

debug "MY GPIODEF: $GPIODEF" 1
if [ "$GPIODEF" = "GPIO_V1" ]
  then
    let TotalGPIO_outputs=11
    let TotalGPIO_inputs=1
    declare -a GPoutputs=(gpio1_pd0 gpio2_pd1 gpio3_pd2 gpio4_pd3 gpio5_pd4 gpio6_pd5 gpio7_pd6 gpio8_pd7 gpio9_pd8 gpio10_pd9 gpio11_pb8)
    declare -a GPinputs=(gpio12_ph12)
    TopRed="$LEDspath/red"
    TopBlue="$LEDspath/blue"
    TopGreen="$LEDspath/green"
    RED_OFF="$GPIOpath/gpio11_pb8"
    BUTTON="$GPIOpath/gpio12_ph12"
    SBMC_RESET="$GPIOpath/gpio1_pd0"
    SBMC_RTS="$GPIOpath/gpio2_pd1"
    SBMC_ERASE="$GPIOpath/gpio3_pd2"
    SBMC_TTY="/dev/ttyS4"
    SBKW_RESET="$GPIOpath/gpio4_pd3"
    SBCC1_RESET="$GPIOpath/gpio5_pd4"
    SBCC1_CLK="$GPIOpath/gpio6_pd5"
    SBCC1_DATA="$GPIOpath/gpio7_pd6"
    SBCC2_RESET="$GPIOpath/gpio8_pd7"
    SBCC2_CLK="$GPIOpath/gpio9_pd8"
    SBCC2_DATA="$GPIOpath/gpio10_pd9"
  elif [ "$GPIODEF" = "GPIO_V2" ]
    then
    let TotalGPIO_outputs=11
    let TotalGPIO_inputs=1
    declare -a GPoutputs=(gpio1_pd0 gpio2_pd1 gpio3_pd2 gpio4_pd3 gpio5_pd4 gpio6_pd5 gpio7_pd6 gpio8_pd7 gpio9_pd8 gpio10_pd9 gpio11_pb8)
    declare -a GPinputs=(gpio12_ph12)
    TopRed="$LEDspath/red"
    TopBlue="$LEDspath/blue"
    TopGreen="$LEDspath/green"
    SBMC_TTY="/dev/ttyS2"
    RED_OFF="$GPIOpath/gpio11_pb8"
    BUTTON="$GPIOpath/gpio12_ph12"
    RESET_DET="$GPIOpath/gpio12_ph12"
    SBMC_RESET="$GPIOpath/gpio10_pd9"
    SBMC_RTS="$GPIOpath/gpio9_pd8"
    SBMC_ERASE="$GPIOpath/gpio8_pd7"
    SBKW_RESET="$GPIOpath/gpio7_pd6"
    SBCC1_RESET="$GPIOpath/gpio6_pd5"
    SBCC1_CLK="$GPIOpath/gpio2_pd1"
    SBCC1_DATA="$GPIOpath/gpio3_pd2"
    SBCC2_RESET="$GPIOpath/gpio4_pd3"
    SBCC2_CLK="$GPIOpath/gpio5_pd4"
    SBCC2_DATA="$GPIOpath/gpio1_pd0"
  elif [ "$GPIODEF" = "GPIO_V2a" ]
    then
    let TotalGPIO_outputs=14
    let TotalGPIO_inputs=1
    declare -a GPoutputs=(gpio1_pd0 gpio2_pd1 gpio3_pd2 gpio4_pd3 gpio5_pd4 gpio6_pd5 gpio7_pd6 gpio8_pd7 gpio9_pd8 gpio10_pd9 gpio11_pb8 gpio13_pb6 gpio14_pb7 gpio15_pb5)
    declare -a GPinputs=(gpio12_ph12)
    TopGreen="$GPIOpath/gpio13_pb6"
    TopBlue="$GPIOpath/gpio14_pb7"
    TopRed="$GPIOpath/gpio15_pb5"
    SBMC_TTY="/dev/ttyS2"
    RED_OFF="$GPIOpath/gpio11_pb8"
    RESET_DET="$GPIOpath/gpio12_ph12"
    SBMC_RESET="$GPIOpath/gpio10_pd9"
    SBMC_RTS="$GPIOpath/gpio9_pd8"
    SBMC_ERASE="$GPIOpath/gpio8_pd7"
    SBKW_RESET="$GPIOpath/gpio7_pd6"
    SBCC1_RESET="$GPIOpath/gpio6_pd5"
    SBCC1_CLK="$GPIOpath/gpio2_pd1"
    SBCC1_DATA="$GPIOpath/gpio3_pd2"
    SBCC2_RESET="$GPIOpath/gpio4_pd3"
    SBCC2_CLK="$GPIOpath/gpio5_pd4"
    SBCC2_DATA="$GPIOpath/gpio1_pd0"
  elif [ "$GPIODEF" = "GPIO_V5" ]
    then
    let TotalGPIO_outputs="$hardware_gpioProfile_NumberOfOutputs"
    let TotalGPIO_inputs="$hardware_gpioProfile_NumberOfInputs"
   declare -a GPoutputs=(gpio1_pd0 gpio2_pd1 gpio3_pd2 gpio4_pd3 gpio5_pd4 gpio6_pd5 gpio7_pd6 gpio8_pd7 gpio9_pd8 gpio10_pd9 gpio11_pb8)
    declare -a GPinputs=(gpio12_ph12)
   TopRed="$hardware_gpioProfile_TopRed"
    TopBlue="$hardware_gpioProfile_TopBlue"
    TopGreen="$hardware_gpioProfile_TopGreen"
    SBMC_TTY="$hardware_radioProfile_SBMC_TTY"
    RED_OFF="$hardware_gpioProfile_RED_OFF"
    RESET_DET="$hardware_gpioProfile_BUTTON"
    SBMC_RESET="$hardware_radioProfile_SBMC_RESET"
    SBMC_RTS="$hardware_radioProfile_SBMC_RTS"
    SBMC_ERASE="$hardware_radioProfile_SBMC_ERASE"
    SBKW_RESET="$GPIOpath/gpio7_pd6"
    SBCC1_RESET="$GPIOpath/gpio6_pd5"
    SBCC1_CLK="$GPIOpath/gpio2_pd1"
    SBCC1_DATA="$GPIOpath/gpio3_pd2"
    SBCC2_RESET="$GPIOpath/gpio4_pd3"
    SBCC2_CLK="$GPIOpath/gpio5_pd4"
    SBCC2_DATA="$GPIOpath/gpio1_pd0"
      elif [ "$GPIODEF" = "GPIO_V6" ]
    then
    let TotalGPIO_outputs="$hardware_gpioProfile_NumberOfOutputs"
    let TotalGPIO_inputs="$hardware_gpioProfile_NumberOfInputs"
   declare -a GPoutputs=(gpio1_pd0 gpio2_pd1 gpio3_pd2 gpio4_pd3 gpio5_pd4 gpio6_pd5 gpio7_pd6 gpio8_pd7 gpio9_pd8 gpio10_pd9 gpio11_pb8)
    declare -a GPinputs=(gpio12_ph12)
   TopRed="$hardware_gpioProfile_TopRed"
    TopBlue="$hardware_gpioProfile_TopBlue"
    TopGreen="$hardware_gpioProfile_TopGreen"
    SBMC_TTY="$hardware_radioProfile_SBMC_TTY"
    RED_OFF="$hardware_gpioProfile_RED_OFF"
    RESET_DET="$hardware_gpioProfile_BUTTON"
    SBMC_RESET="$hardware_radioProfile_SBMC_RESET"
    SBMC_RTS="$hardware_radioProfile_SBMC_RTS"
    SBMC_ERASE="$hardware_radioProfile_SBMC_ERASE"
    SBKW_RESET="$GPIOpath/gpio7_pd6"
    SBCC1_RESET="$GPIOpath/gpio6_pd5"
    SBCC1_CLK="$GPIOpath/gpio2_pd1"
    SBCC1_DATA="$GPIOpath/gpio3_pd2"
    SBCC2_RESET="$GPIOpath/gpio4_pd3"
    SBCC2_CLK="$GPIOpath/gpio5_pd4"
    SBCC2_DATA="$GPIOpath/gpio1_pd0"
  else
    declare -a GP=(gpio1_ph12 gpio2_pc21 pio3_pc20 gpio4_pc19 gpio5_pb8 gpio6_pb13 gpio7_ph8 gpio8_pb4 gpio9_pb2 gpio10_pi12)
    TotalGPIOs_outputs=9
    TotalGPIO_inputs=1
fi

TotalGPIOs=$(($TotalGPIO_inputs+$TotalGPIO_outputs))

function modprobe_gpiodriver() {
modprobe gpio-sunxi
}




function LoopthroughGPIOs() {
  debug "LoopthroughGPIOs($1)" 1
 for i in $(seq 1 $TotalGPIOs) 
 do 
  debug "setting: 'echo $i > $1'" 2
  echo $i > $1
 done
}


function exportGPIOs() {
  LoopthroughGPIOs "/sys/class/gpio/export" 
}

function unexportGPIOs() {
  LoopthroughGPIOs "/sys/class/gpio/unexport" 
}






function setdirection () {
  debug "setdirection()" 1
  let count=TotalGPIO_outputs-1
  #outputs
  for i in  $(seq 0 $count)
  do
    GP_D=$GPIOpath/${GPoutputs[$i]}/direction
    debug "setting: '$i) echo out > $GP_D" 2
    echo out > $GP_D
  done
   let count=TotalGPIO_inputs-1
  #inputs
  for i in  $(seq 0 $count)
  do
    GP_D=$GPIOpath/${GPinputs[i]}/direction
    debug "setting: '$i) echo in > $GP_D" 2
    echo "in" > $GP_D
  done  
}

if [ "$#" -lt 1 ]; then
    modprobe_gpiodriver
    exportGPIOs
    setdirection
      $GPIO_THISDIR/control-LED.sh red
    echo 1 > $RED_OFF/value
fi

