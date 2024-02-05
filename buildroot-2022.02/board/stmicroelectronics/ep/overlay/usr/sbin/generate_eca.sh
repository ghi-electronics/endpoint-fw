#!/bin/bash
#script to loop through directories to merge files
echo File found: > /root/config.eca

find "$1" -print0 | while read -d $'\0' file; do
	if [[ -d "$file" ]]; then
		echo D:"$file" >> /root/config.eca
	else
		echo F:"$file" >> /root/config.eca
	fi
done

sync
