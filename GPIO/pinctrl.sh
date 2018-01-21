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
	case $1 in
	#
	"wdog_reset") echo $2 > $gpio_root/gpio$wdog_reset/value; ;;
esac

}


exportall
main $@