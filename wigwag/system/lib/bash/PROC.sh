#!/bin/bash

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

LOCKDIR=/var/lock

PROC_block(){
	local lock="$1"
	log debug	"lockfile-create -r 0 $LOCKDIR/$lock"
	lockfile-check "$LOCKDIR/$lock"
	if [[ $? -eq 0 ]]; then
		echo 2
	else
		lockfile-create -r 0 "$LOCKDIR/$lock"
		if [[ $? -eq 0 ]]; then
			log info "Lockfile: locked"
			echo 1
		else
			echo 0
		fi
	fi
}

PROC_unblock(){
	local lock="$1"
	lockfile-remove "$LOCKDIR/$lock"
	if [[ $? -eq 0 ]]; then
		log info "Lockfile: unlocked"
		return 0
	else
		return 1
	fi
}

PROC_updateblock(){
	local lock="$1"
	lockfile-touch -o "$LOCKDIR/$lock"
	if [[ $? -eq 0 ]]; then
		log info "Lockfile: updated lock"
		return 0
	else
		return 1
	fi
}