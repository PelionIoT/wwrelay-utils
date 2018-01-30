#!/bin/bash
PD3=99
wdog_reset=$PD3
gpio_root=/sys/class/gpio


exportall(){
	pushd . >> /dev/null
	cd $gpio_root
	echo "$wdog_reset" >> export 2> /dev/null
	echo "out" > gpio$wdog_reset/direction
	popd >> /dev/null
}


main(){
	gpio=$gpio_root/gpio$1/
	case $2 in
		#
		"enable") echo 1 > $gpio/value; ;;
		#
		"disable") echo 0 > $gpio/value; ;;
		#
		"out" ) echo "out" > $gpio/direction; 
			#
			if [[ $3 -eq 1 || $3 -eq 0]]; then 
				echo $3 > $gpio/value;
			fi
			;;
		#
		"in" ) echo "in" > $gpio/direction; ;;
		#
	esac
}


exportall
main $@


#pinctrl wdag enable
#pinctrl wdog out 1
#pinctrl wdog in
