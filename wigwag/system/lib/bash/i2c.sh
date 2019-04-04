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

#-----------------------------------------------------------------------------------------------------------------------
#  utils i2c
#-----------------------------------------------------------------------------------------------------------------------

#/	Desc:	erases the page called
#/	Ver:	.1
#/	$1:		page
#/	Out:	n/a
#/	Expl:	i2c_erasePage 0x50
i2c_erasePage(){
	local page="$1"
	local erasei
	for erasei in {0..255}; do 
		i2cset -y 1 $page $erasei 0xff b; 
	done
} #end_i2c_erasePage

#/	Desc:	erases one character with 0xFF
#/	Ver:	.1
#/	$1:		page
#/	$2:		posisition
#/	$3:		
#/	Out:	n/a
#/	Expl:	i2c_eraseOne 0x50 21
i2c_eraseOne(){
	local page="$1"
	local position="$2"
	i2cset -y 1 $page $position 0xff b; 
} #end_i2c_eraseOne

#/	Desc:	grabs one character from the Eerpom
#/	Ver:	.1
#/	$1:		page
#/	$2:		position
#/	Out:	outputs the character in native format
#/	Expl:	hex=(i2c_getOne 0x50 2)
i2c_getOne(){
	local page="$1"
	local position="$2"
	log silly "i2cget -y 1 $page $position b"
		a=$(i2cget -y 1 $page $position b) 
	echo $a
} #end_i2c_getOne

#/	Desc:	sets one character via the i2cset command
#/	Ver:	.1
#/	$1:		page
#/	$2:		position
#/	$3:		hexvalue
#/	Out:	n/a
#/	Expl:	i2c_setOne 0x50 20 0x33
i2c_setOne(){
	local page="$1"
	local position="$2"
	local hexvalue="$3"
	log silly "i2cset -y 1 $page $position $hexvalue"
		a=$(i2cset -y 1 $page $position $hexvalue)
	#echo $a
} #end_i2c_setOne