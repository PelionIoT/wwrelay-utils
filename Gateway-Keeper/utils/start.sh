#!/usr/bin/expect -f

set workDir [pwd]
set IP [lindex $argv 0];
set username [lindex $argv 1];

spawn node utils/relayIP.js
expect "$ "

set i [open ".samplelist"]
set hosts [split [read -nonewline $i] "\n"]
send_user "\n============================================================================================= \n"
set timeout -1
foreach host $hosts {
	spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null maestro@$host
	sleep 2
	expect "assword: "
	send "maestro\r"
	expect "$ "
	send "su -\r"
	expect "assword: "
	send "wigwagr0x\r"
	expect -re ".*wigwag.*"
	send "mkdir /home/maestro\r"
	expect "# "
	send "chown maestro /home/maestro\r"
	expect "# "
	send "exit\r"
	expect "$ "
	send "exit\r"
	expect "$ "
	spawn scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $workDir/src/relayClient.js maestro@$host:~
	expect "assword: "
	send "maestro\r"
	expect "$ "
	spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null maestro@$host
	sleep 2
	expect "assword: "
	send "maestro\r"
	expect "$ "
	send "su -\r"
	expect "assword: "
	send "wigwagr0x\r"
	expect -re ".*wigwag.*"
	send "mv /home/maestro/relayClient.js ./\r"
	expect "# "
	send "NODE_PATH=/wigwag/devicejs-core-modules/node_modules/ node relayClient.js $IP > /dev/null &\r"
	expect "# "
	send "exit\r"
	expect "$ "
	send "exit\r"
	expect eof
	send_user "============================================================================================= \n\n"
}