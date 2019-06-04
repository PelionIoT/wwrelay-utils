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

kill `ps -ef | grep alert- | awk '{print $2}'`
sleep 2
echo 'Starting alert-tooDark-virtual'
/wigwag/devicejs-ng/bin/devicejs run ./alert-tooDark-virtual.js --config=/wigwag/etc/devicejs/devicejs.conf >& tooDark.log &
sleep 1
echo 'Starting alert-temperatureTooLow'
/wigwag/devicejs-ng/bin/devicejs run ./alert-temperatureTooLow.js --config=/wigwag/etc/devicejs/devicejs.conf >& temperatureTooLow.log &