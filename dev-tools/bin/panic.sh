#!/bin/bash

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
