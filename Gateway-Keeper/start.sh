#!/usr/bin/expect -f

spawn node relayIP.js
expect "$ "

set i [open "samplelist"]
set hosts [split [read -nonewline $i] "\n"]

set timeout -1
foreach host $hosts {
	#set myIP [lindex $argv 0] 
	spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null maestro@$host
	sleep 2
	expect "assword: "
	send "maestro\r"
	expect "$ "
	send "su -\r"
	expect "assword: "
	send "wigwagr0x\r"
	expect -re ".*wigwag.*"
	send "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null bhoopesh@192.168.0.114:/home/bhoopesh/workspace/Gateway-Keeper/relayClient.js ./\r"
	expect "password: "
	send "Bhoope@123\r"
	expect "# "
	send "killall relayClient.js\r"
	expect "# "
	send "NODE_PATH=/wigwag/devicejs-core-modules/node_modules/ node relayClient.js &\r"
	expect "# "
	send "exit\r"
	expect "$ "
	send "exit\r"
	expect eof
	#interact
	#expect "a"
}