#!/bin/bash

WIGWAGROOT="/wigwag"
DEVICEDB_CMD="/usr/bin/devicedb"
DEVICEDB_LOG="${WIGWAGROOT}/log/devicedb.log"
DEVICEDB_CONF="${WIGWAGROOT}/etc/devicejs/devicedb.yaml"

function run_devicedb() {
	while true; do
		$DEVICEDB_CMD start -conf=$DEVICEDB_CONF >> $DEVICEDB_LOG 2>&1
		sleep 1
	done
}

run_devicedb