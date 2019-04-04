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

BUILD=$1
workDir=$(pwd)
DIRECTORY='./build'

if [ ! -d "$DIRECTORY" ]; then
	mkdir build
fi 

if [[ $BUILD ]];then
	rm -rf ./build/*
	sudo wget -O $workDir/../build/$BUILD-field-factoryupdate.tar.gz https://code.wigwag.com/ugs/builds/development/cubietruck/$BUILD-field-factoryupdate.tar.gz --no-check-certificate
fi
