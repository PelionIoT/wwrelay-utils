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

BAUD_BASE=1500000
DEV=$1
DIVISOR=10
UART=16550A
#UART=16450
CUSTOMBAUD=38400
#CUSTOMBAUD=115200
# https://github.com/cbrake/linux-serial-test


function custom {
	setserial -a $DEV baud_base $BAUD_BASE divisor $DIVISOR UART $UART spd_cust
	stty -F $DEV $CUSTOMBAUD
	echo "now the values"
	setserial -a $DEV
	stty -F $DEV -a
	echo "now sending a U"
	echo -n "U" > $DEV
}

function regular_set {
	setserial -a $DEV baud_base $BAUD_BASE divisor $DIVISOR UART $UART spd_normal
	stty -F $DEV 115200
	echo "now the values"
	setserial -a $DEV
	stty -F $DEV -a
	echo "now sending a U"
	echo -n "U" > $DEV
}

function longsend {
	./linux-serial-test -s -p $DEV -b 115200
}

function shortsend {
	linux-serial-test -y 0x55 -z 0x0 -p $DEV -b 115200
}

regular_set
./linux-serial-test -s -p $DEV -b 115200

#if [[ "$1" = "regular" ]]; then
#	regular_set
#else
#	longsend
#fi