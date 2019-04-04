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

#to moniter the progress of the panic loop, you can setup a mini server with netcat.  The following server example will simply catch the panic loop counter.  clearly you can do whatever you want with the data.  This is just an example of how to catch the data.

#server side nc program to catch the count thrown from this program...
#!/bin/bash
# ncloop(){ 
# while true; do 
# catch=$(netcat --l p 2233)
# echo $catch 
# #do whatever you want here....
# }
#ncloop 


paniccounterlog=/wigwag/log/panic.log

server=""
server_port="2233"

if [[ $1 = "" ]]; then
	sleepytime=1
else
	sleepytime="$1"
fi
sleep $sleepytime
if [[ ! -e $paniccounterlog ]]; then
	ccc=1
else
	ccc=$(cat $paniccounterlog)
	ccc=$(($ccc + 1))
fi
	echo $ccc > $paniccounterlog
	sync
	if [[ $server != "" ]]; then
		echo $ccc | nc $server $server_port
	fi
	killall node
	sleep 4
	#led 1 1 1
modprobe panic
