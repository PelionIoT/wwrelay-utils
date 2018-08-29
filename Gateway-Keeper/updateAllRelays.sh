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
	send "rm -rf /wigwag/log/devicejs.log\r"
	expect "# "
	send "killall maestro\r"
	expect "# "
	send "/etc/init.d/devicejs start\r"
	expect "# "
	send "udhcpc\r"
	expect "# "
	send "upgrade -F -t -U -v -w -S -r https://code.wigwag.com/ugs/builds/development/cubietruck/102.0.353-field-factoryupdate.tar.gz &\r"
	expect "# "
	send "exit\r"
	expect "$ "
	send "exit\r"
	expect eof
}