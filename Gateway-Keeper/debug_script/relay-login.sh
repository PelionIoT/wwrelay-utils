#!/usr/bin/expect -f

set IP [lindex $argv 0];
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null maestro@$IP
sleep 2
expect "assword: "
send "maestro\r"
expect "$ "
send "su -\r"
expect "assword: "
send "wigwagr0x\r"
expect -re ".*wigwag.*"
interact