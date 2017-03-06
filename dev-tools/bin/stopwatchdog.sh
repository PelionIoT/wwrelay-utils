#!/bin/bash
KEEPALIVE="/var/deviceOSkeepalive"
STOP_DEVICEOSWD_CMD="echo -e \"stop\" | socat unix-sendto:$KEEPALIVE STDIO"
eval "$STOP_DEVICEOSWD_CMD"
killall deviceOSWD
rm /var/run/deviceOSWD.pid
