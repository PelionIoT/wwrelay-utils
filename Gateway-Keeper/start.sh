#!/usr/bin/expect -f
# set username [lindex $argv 0];
# set IP [lindex $argv 1];
# set password [lindex $argv 2];
# set build [lindex $argv 3];
set workDir [pwd]

# username=$(whoami)
# IP=$(ifconfig | grep -A 2 -E 'wlan|eth|wlp3s0|enp0s25' | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
# echo "Your IP is -- $IP"
set IP [lindex $argv 0];
set username [lindex $argv 1];

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
	send "mkdir /home/maestro\r"
	expect "# "
	send "chown maestro /home/maestro\r"
	expect "# "
	send "exit\r"
	expect "$ "
	send "exit\r"
	expect "$ "
	spawn scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $workDir/relayClient.js maestro@$host:~
	expect "assword: "
	send "maestro\r"
	expect "$ "
	# send "su -\r"
	# expect "assword: "
	# send "wigwagr0x\r"
	# expect -re ".*wigwag.*"
	# #spawn cat ~/.ssh/relay_rsa.pub | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null maestro@$host "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"
	# expect "assword: "
	# send "maestro\r"
	# expect "$ "
	# send "su -\r"
	# expect "assword: "
	# send "wigwagr0x\r"
	# expect -re ".*wigwag.*"
	# send "mkdir /home/maestro\r"
	# expect "# "
	# send "chown maestro:maestro /home/maestro\r"
	# expect "# "
	# send "exit\r"
	# expect "$ "
	# send "exit\r"
	# expect "$ "
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
	send "killall relayClient.js\r"
	expect "# "
	send "NODE_PATH=/wigwag/devicejs-core-modules/node_modules/ node relayClient.js $IP &\r"
	expect "# "
	send "exit\r"
	expect "$ "
	send "exit\r"
	expect eof
	# spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null maestro@$host
	# send "cd /home/root\r"
	# expect "# "
	# send "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $username@$IP:$workDir/relayClient.js ./\r"
	# expect "# "
	# send "killall relayClient.js\r"
	# expect "# "
	# send "NODE_PATH=/wigwag/devicejs-core-modules/node_modules/ node relayClient.js $IP &\r"
	# expect "# "
	# send "exit\r"
	# expect "$ "
	# send "exit\r"
	# expect eof
	send_user "============================================================================================= \n\n"
}