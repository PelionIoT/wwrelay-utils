#!/bin/bash
#/	Desc:	does nothing.  Used when including the common script
#/	Expl:	source common.sh nofunc
nofunc(){
	:
} #end_nofunc

getIP(){
	echo $(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
} #end_getIP


#depricated
getCurrentIP(){
	echo "getCurrentIP is depricated"
	getIP $@
} #end_getCurrentIP