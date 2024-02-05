#!/bin/bash

busybox ps > /root/.epdata/busyboxps.txt
appid="$(cat /root/.epdata/busyboxps.txt | grep '/root/.epdata/' | awk '{print $1}')"

if [ -n "$appid" ]; then
	kill -9 $appid
	echo "Done stop"
fi

rm /root/.epdata/busyboxps.txt
sync
