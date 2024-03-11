#!/bin/bash

count=`ls /dev/|grep "^sd"|grep '1$'|wc -l`
echo $count > /opt/diskNum.txt
while [ 1 ]
do 
	num=`ls /dev/|grep "^sd"|grep '1$'|wc -l`
	if [ $count -lt $num ]
	then
		disk=`find /dev/|grep '^/dev/sd'|grep '1$'|head -1`
		echo $disk /opt/disk.txt
		mount $disk /mnt/usb
		break
	fi
done
echo OK
