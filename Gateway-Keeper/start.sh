#!/usr/bin/expect -f
set username [lindex $argv 0];
set IP [lindex $argv 1];
set password [lindex $argv 2];
set build [lindex $argv 3];
set workDir [pwd]

if {[llength $argv] == 0} {
  send_user " \n Usage: sudo <scriptname> \[username\] \[IP\] \[password\] \[build\]\n\n"
  exit 1
}

spawn node relayIP.js
expect "$ "

set i [open "samplelist"]
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
	send "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $username@$IP:$workDir/relayClient.js ./\r"
	expect "password: "
	send "$password\r"
	expect "# "
	send "killall relayClient.js\r"
	expect "# "
	send "NODE_PATH=/wigwag/devicejs-core-modules/node_modules/ node relayClient.js $IP $build&\r"
	expect "# "
	send "exit\r"
	expect "$ "
	send "exit\r"
	expect eof
	send_user "============================================================================================= \n\n"
}