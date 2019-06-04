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

SCRIPT_DIR="/wigwag/wwrelay-utils/debug_scripts"
# SCRIPT_DIR="/home/yashgoyal/workspace/wwrelay-utils/debug_scripts"
restart_services() {
	cd $SCRIPT_DIR
	chmod 755 detect_platform.sh
	source ./detect_platform.sh
	# if [ $hardwareversion == "RP200" ] || [ $hardwareversion == "RP100" ]; then
        echo "Rebooting the GW!"
		# reboot
    # elif [ $hardwareversion == "SOFT_GW" ]; then
        # echo "On SOFT_GW! Restarting the services."
	    echo "Stopping maestro processes..."
		killall maestro
		killall maestro
		killall run_mbed_edge_core.sh
		killall run_mbed_edge_core.sh
		killall check_edge_connection.sh
		killall check_edge_connection.sh

		echo "Stopping edge core..."
		#killall edge-core
		/etc/init.d/wwrelay start
		/etc/init.d/maestro.sh start
    # else
        # echo "Unknown platform! Do not know how to restart the edge services..."
	# fi
}

restart_services
