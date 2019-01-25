#!/bin/bash

KEEPALIVE="/var/deviceOSkeepalive"
PIEZO_TONE="echo -e \"piezo_tone $1\" | socat unix-sendto:$KEEPALIVE STDIO"
eval "$PIEZO_TONE"
