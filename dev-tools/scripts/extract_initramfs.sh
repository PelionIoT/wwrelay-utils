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

if [[ $1 = "--help" || $1 = "-h" || $1 = "" || $1 != *"initramfs.img" ]]; then
	echo "Useage: $0 <initramfs.img>"
fi
tempdir=$(mktemp -d)
dd if=$1 of=$tempdir/initramfs.igz bs=64 skip=1
cd $tempdir
cat $tempdir/initramfs.igz | gunzip | cpio -idmv
echo "your files are in $tempdir"
rm -rf $tempdir/initramfs.igz