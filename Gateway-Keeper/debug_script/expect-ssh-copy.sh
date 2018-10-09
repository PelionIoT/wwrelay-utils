#!/usr/bin/expect -f

set workDir [pwd]
set IP [lindex $argv 0];
set BUILD [lindex $argv 1]
send_user "\n============================================================================================= \n"
spawn scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $workDir/build/$BUILD-field-factoryupdate.tar.gz maestro@$IP:~
set timeout 120
expect "assword: "
send "maestro\r"
expect "maestro@wigwagrelay:~$ "
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null maestro@$IP
expect "assword: "
send "maestro\r"
expect "$ "
send "su -\r"
expect "assword: "
send "wigwagr0x\r"
expect -re ".*wigwag.*"
send "mv /home/maestro/$BUILD-field-factoryupdate.tar.gz /upgrades/\r"
expect "# "
send "cd /upgrades\r"
expect "# "
send "upgrade -F -t -U -v -w -S -r $BUILD-field-factoryupdate.tar.gz &\r"
expect "# "
send "exit\r"
expect "$ "
send "exit\r"
expect eof
send_user "============================================================================================= \n\n"
