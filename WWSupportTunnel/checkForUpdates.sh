#!/bin/bash
sleep 12h
while true; do
    echo "Sending update command to wigwagupdater..."
    response=$(curl -s -o /dev/null -w %{http_code} -X POST http://127.0.0.1:3000/updateAll)
    echo "Response from wigwagupdater = " $response

	if [ $response -eq 200 ]
	then
	  echo "Success sending updateAll to wigwagupdater - next check in 1h"
	  sleep 1h
	else
	  echo "Failure sending updateAll to wigwagupdater - next check in 1m"
	  sleep 1m
	fi
	echo "=========================================================================="
done
