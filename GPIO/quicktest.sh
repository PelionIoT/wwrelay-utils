#!/bin/bash
echo 37 > /sys/class/gpio/export
echo 38 > /sys/class/gpio/export
echo 236 > /sys/class/gpio/export

echo out > /sys/class/gpio/gpio38/direction
echo out > /sys/class/gpio/gpio37/direction
echo 

SCLK=/sys/class/gpio/gpio38/value
#SCLK=/sys/devices/platform/soc@01c00000/1c20800.pinctrl/gpio/gpio38/value
SDATA=/sys/class/gpio/gpio37/value

#SCLK=/sys/class/gpio/gpio12_pb6/value
#SDATA=/sys/class/gpio/gpio11_pb5/value	

red=25
green=25
blue=25
nDots=1
re='^[0-9]+$'


function dec2hex() {
  out=$(echo "obase=16;ibase=10; $1" | bc)
  echo "0x$out"
}

function dec2bin() {
  out=$(echo "obase=2;ibase=10; $1" | bc)
  echo "0x$out"
}

# echo 1 > $SDATA
# echo 1 > $SCLK
# echo 0 > $SCLK

# function color2() {

# 	red=$1
# 	blue=$3
# 	green=$2

# 		echo "red: $red green $green blue $blue"
# for ((i=0; i<32; i++)); do 
# echo 1 > $SCLK
# echo 0 > $SCLK
# 	echo "i) $i"
# #pio -m PB6\<1\>\<0\>\<1\>\<1\>
# #pio -m PB6\<1\>\<0\>\<1\>\<0\>
# done

# for ((i=0;i<$nDots;i++)); do
# 	echo 1 > $SDATA
# 	echo 1 > $SCLK
# 	echo 0 > $SCLK
# 	echo "i2i) $i"
# Mask=16
# 	for ((j=0; j < 5; j++)); do
# 		#echo "Mask: $Mask 0x" $(dec2hex $Mask) $(dec2bin $Mask)
# 		#echo "red : $red 0x" $(dec2hex $red) $(dec2bin $red)
# 		#echo "red : $red 0x" $(dec2hex $red) 
# 		maskfilter=$(( $Mask & $red ))
# 		#echo "===== " $maskfilter
# 		if [[ $maskfilter -eq 0 ]]; then
# 			echo 0 > $SDATA
# 		else 
# 			echo 1 > $SDATA
# 		fi
# 		echo 1 > $SCLK
# 		echo 0 > $SCLK	
# 		let "Mask >>= 1"
# 	done
# Mask=16
# 	for ((j=0; j < 5; j++)); do
# 		#echo "Mask: $Mask 0x" $(dec2hex $Mask) $(dec2bin $Mask)
# 		#echo "red : $red 0x" $(dec2hex $red) $(dec2bin $red)
# 		#echo "red : $red 0x" $(dec2hex $red) 
# 		maskfilter=$(( $Mask & $blue ))
# 		#echo "===== " $maskfilter
# 		if [[ $maskfilter -eq 0 ]]; then
# 			echo 0 > $SDATA
# 		else 
# 			echo 1 > $SDATA
# 		fi
# 		echo 1 > $SCLK
# 		echo 0 > $SCLK	
# 		let "Mask >>= 1"
# 	done
# Mask=16
# 	for ((j=0; j < 5; j++)); do
# 		#echo "Mask: $Mask 0x" $(dec2hex $Mask) $(dec2bin $Mask)
# 		#echo "red : $red 0x" $(dec2hex $red) $(dec2bin $red)
# 		#echo "red : $red 0x" $(dec2hex $red) 
# 		maskfilter=$(( $Mask & $green ))
# 		#echo "===== " $maskfilter
# 		if [[ $maskfilter -eq 0 ]]; then
# 			echo 0 > $SDATA
# 		else 
# 			echo 1 > $SDATA
# 		fi
# 		echo 1 > $SCLK
# 		echo 0 > $SCLK	
# 		let "Mask >>= 1"
# 	done
# done
# echo 0 > $SDATA
# for ((i=0; i<$nDots; i++)); do
# 	echo 1 > $SCLK
# 	echo 0 > $SCLK	
# done
# echo "done setting color"
# }

# function cycleit() {
# 	while (true); do
# 		for r in {0..30}; do
# 		for g in {0..30}; do
# 			for b in {0..30}; do
# 			color $r $g $b
# 		done	
# 		done		
# 		done	

# 	done

# }

	
color() {
	red=$1
	blue=$3
	green=$2
#	echo "red: $red green $green blue $blue"
	for i in `seq 0 31`; do
		echo 1 > $SCLK
		echo 0 > $SCLK
	done

	for i in `seq 0 0`; do
		echo 1 > $SDATA
		echo 1 > $SCLK
		echo 0 > $SCLK
		Mask=16
		for j in `seq 0 4`; do
			maskfilter=$(( $Mask & $red ))
			if [[ $maskfilter -eq 0 ]]; then
				echo 0 > $SDATA
			else 
				echo 1 > $SDATA
			fi
			echo 1 > $SCLK
			echo 0 > $SCLK	
			let "Mask >>= 1"
		done
		Mask=16
		for j in `seq 0 4`; do
			maskfilter=$(( $Mask & $blue ))
			if [[ $maskfilter -eq 0 ]]; then
				echo 0 > $SDATA
			else 
				echo 1 > $SDATA
			fi
			echo 1 > $SCLK
			echo 0 > $SCLK	
			let "Mask >>= 1"
		done
		Mask=16
		for j in `seq 0 4`; do
			maskfilter=$(( $Mask & $green ))
			if [[ $maskfilter -eq 0 ]]; then
				echo 0 > $SDATA
			else 
				echo 1 > $SDATA
			fi
			echo 1 > $SCLK
			echo 0 > $SCLK	
			let "Mask >>= 1"
		done
	done
	echo 0 > $SDATA
	for j in [0-1]; do
		echo 1 > $SCLK
		echo 0 > $SCLK	
	done
}

timout=5
state="starting";
LED_reboot="0 7 0" #green
LED_wipe_user="18 3 0" #orange
LED_wipe_upgrade="12 0 12" #purple
LED_wipe_all_wget="0 10 10" #cyan



do_state_command() {
	case $state in                                                                                                                                                                                                                                    
        "reboot")   
            color $LED_reboot                                                                                                                                                                                                                       
            echo init6                                                                                                                                                                                                             
            ;;                                                                                                                                                                                                                                    
        "wipe_user")  
        	color $LED_wipe_user                                                                                                                                                                                                                               
            echo "wipe user partition"                                                                                                                                                                                    
            ;;                                                                                                                                                                                                                                    
        "wipe_upgrade")
			color $LED_wipe_upgrade
        	echo "wipe upgrade"                                                                                                                                                                                            
            ;;                                                                                                                                                                                                                                    
        "wipe_all_wget")
			color $LED_wipe_all_wget
        	echo "wipe_all_wget"                                                                                                                                                                                               
            ;;                                                                                                                                                                                                                                    
    esac 



}


button_up() {
 	case $state in                                                                                                                                                                                                                               
        "starting")                                                                                                                                                                                                                                
            color $LED_reboot
            state="reboot"                                                                                                                                                                                                                
            ;;                                                                                                                                                                                                                                    
        "reboot")                                                                                                                                                                                                                                   
            color $LED_wipe_user
            state="wipe_user"                                                                                                                                                                                                                 
            ;;                                                                                                                                                                                                                                    
        "wipe_user")                                                                                                                                                                                                                                 
            color $LED_wipe_upgrade 
            state="wipe_upgrade"                                                                                                                                                                                        
            ;;                                                                                                                                                                                                                                    
        "wipe_upgrade")                                                                                                                                                                                                                                
          color $LED_wipe_all_wget
          state="wipe_all_wget"                                                                                                                                                                                             
            ;;                                                                                                                                                                                                                                    
        "wipe_all_wget")                                                                                                                                                                                                                                 
            color $LED_reboot
            state="reboot"                                                                                                                                                                                                  
            ;;                                                                                                                                                                                                                                    
    esac 
}

state_blink() {
	case $state in                                                                                                                                                                                                                                 
        "reboot")                                                                                                                                                                                                                                   
            color $LED_reboot                                                                                                                                                                                                            
            ;;                                                                                                                                                                                                                                    
        "wipe_user")                                                                                                                                                                                                                                 
            color $LED_wipe_user                                                                                                                                                                   
            ;;                                                                                                                                                                                                                                    
        "wipe_upgrade")                                                                                                                                                                                                                                
          color $LED_wipe_upgrade                                                                                                                                                                                         
            ;;                                                                                                                                                                                                                                    
        "wipe_all_wget")                                                                                                                                                                                                                                 
            color $LED_wipe_all_wget                                                                                                                                                                                         
            ;;                                                                                                                                                                                                                                    
    esac 
    color 0 0 0
    color 0 0 0
    color 0 0 0
}



lastbutton=0;
# 1 is up
recovery() {
	state="starting"
	echo lets recover
	lastbutton=$(cat /sys/class/gpio/gpio236/value)
	secnow=$(date +%s)
	event_start=$secnow
	secnow=$(date +%s)
	elapsed=$(( $secnow - $event_start ))
	buttonstate=0
	color 20 0 0
	locked=1;
	#echo my elapsed $elapsed
	while [ $elapsed -lt 10 ]; do 
		secnow=$(date +%s)
		elapsed=$(( $secnow - $event_start ))
		newbutton=$(cat /sys/class/gpio/gpio236/value)
		if [[ $newbutton -ne $lastbutton ]]; then
			lastbutton=$newbutton
			event_start=$secnow
			if [[ $newbutton -eq 1 ]]; then
				button_up
			fi
			#echo "got a button, starting timer over ($elapsed)"
		fi
	done
	echo "Starting second phase"
	while [ $locked -eq 1 ]; do
		state_blink
		newbutton=$(cat /sys/class/gpio/gpio236/value)
		if [[ $newbutton -ne $lastbutton ]]; then
			lastbutton=$newbutton
			if [[ $newbutton -eq 1 ]]; then
				do_state_command
				locked=0
			fi
		fi	
	done

}


if [[ $1 = "cycle" ]]; then
	cycleit
elif [[ $1 = "recovery" ]]; then
	recovery
elif [[ $1 =~ $re ]] ; then
   red=$1
   green=$2
   blue=$3
   echo "calling color"
   color $red $green $blue
else
	color $red $green $blue	
fi


