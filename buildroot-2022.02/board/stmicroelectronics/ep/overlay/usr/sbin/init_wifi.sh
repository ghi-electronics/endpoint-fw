#!/bin/sh
#
# user startup scripts
#

WPA_CONF_FILE=~/wpa_conf.conf

do_start()
{
	printf "Startig WiFi...\n"
	ln -s /usr/sbin/rfkill /dev/

	modprobe 8188eu
	sleep 1

	ifconfig wlan0 up
	sleep 1		
	
	wpa_supplicant -B -i wlan0 -c ${WPA_CONF_FILE} 	
	sleep 1
	
	dhcpcd wlan0

}

if [ "$1" = "" ] ; then
	if [ -f ${WPA_CONF_FILE} ] ; then
		printf "Found WiFi config...\n"
		
		
	else	 			
		printf "Error: Not found WiFi config\n"
		exit 1						
	fi
		
else
	if [ "$2" = "" ] ; then
		printf "Error: PASS empty\n"		
		exit 2
	fi
	
	printf "Saving WiFi config...\n"
	wpa_passphrase $1 $2 > $WPA_CONF_FILE

fi

do_start

exit 0




