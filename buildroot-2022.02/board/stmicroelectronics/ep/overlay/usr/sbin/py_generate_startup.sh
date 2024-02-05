#!/bin/bash


if [[ $1 -eq 1 ]]; then
	echo -e "export DOTNET_ROOT=/root/.epnet/.dotnet" > "$2"
	echo -e "while [ ! -d /root/.epdata ]; do sleep 0.01; done" >> "$2"
	echo "python $3 & exit 0"  >> $2
	chmod +x $2
fi

if [[ $1 -eq 0 ]]; then
	if [[ -f "$2" ]]; then
		rm "$2"
	fi
fi

sync
