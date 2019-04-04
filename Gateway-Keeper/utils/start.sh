#!/usr/bin/expect -f

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