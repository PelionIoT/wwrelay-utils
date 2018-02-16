#!/bin/bash
/home/root/devmem2 0x01c20c94 w > /wigwag/log/wdog.log
while true; do
/home/root/devmem2 0x01c20c94 w >> /wigwag/log/wdog.log
done
