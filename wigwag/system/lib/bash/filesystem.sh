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

#---------------------------------------------------------------------------------------------------------------------------
# filesystem library
#---------------------------------------------------------------------------------------------------------------------------
fs_help(){
	:
}

fs_mkdirp(){
	if [[ ! -d "$1" ]]; then
		mkdir -p "$1"
	fi
}

fs_touch(){
	if [[ ! -e "$1" ]]; then
		touch "$1"
	fi
}

fs_mktempd(){
	mktemp -d
}