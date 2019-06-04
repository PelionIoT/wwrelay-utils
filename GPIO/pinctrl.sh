#!/bin/bash

# Copyright (c) 2018, Arm Limited and affiliates.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PD3=99
wdog_reset=$PD3
gpio_root=/sys/class/gpio

_doexport() {
	if [[ ! -e ./gpio$1 ]]; then
		echo "exporting $1"
		echo "$wdog_reset" >> export 2> /dev/null
		echo "out" > gpio$1/direction
	fi
}

exportall(){
	pushd . >> /dev/null
	cd $gpio_root
	_doexport $wdog_reset
	popd >> /dev/null
}


main(){
	#echo "gpio=$gpio_root/gpio${!1}/"
	gpio=$gpio_root/gpio${!1}
	case $2 in
		#
		"enable") echo 1 > $gpio/value; ;;
		#
		"disable") echo 0 > $gpio/value; ;;
		#
		"out" ) echo "out" > $gpio/direction; 
			#
			if [[ $3 = "1" || $3 = "0" ]]; then 
				echo "my 3 $3"
				echo $3 > $gpio/value;
			fi
			;;
		#
		"in" ) echo "in" > $gpio/direction; ;;
		#
		"1") echo 1 > $gpio/value; ;;
		#
		"0") echo 0 > $gpio/value; ;;
		#
		*) echo "$(cat $gpio/direction): $(cat $gpio/value)"; ;;
		#
	esac
}



exportall
if [[ $1 = "" ]]; then
	echo "Useage: $0 wdog_reset <out | in | enable | disable>"
fi
main $@


#pinctrl wdag enable
#pinctrl wdog out 1
#pinctrl wdog in
