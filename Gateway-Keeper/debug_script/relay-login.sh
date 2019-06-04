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