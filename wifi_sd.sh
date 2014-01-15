#!/bin/bash
if [ $EUID -ne 0 ]; then
	echo " This script must be run as root" 1>&2
	exit 1
fi
cont=1
while [[ $cont -ge 1 ]]; do
	log=`system_profiler SPAirPortDataType |grep "Supported Channels:"`
	echo $log
	echo -n "Restarting AirPort [$cont] ..."
	sudo networksetup -setairportpower en0 off
	sleep 2
	sudo networksetup -setairportpower en0 on
	sleep 2
	let "cont+=1"
	echo "DONE"
done
exit 0
