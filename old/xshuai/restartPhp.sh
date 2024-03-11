#!/bin/bash
while true
do
	count=$(/bin/ps -ef |grep "/usr/local/m1905/php/etc/php-fpm.conf"|grep -v grep |wc -l)
	if [ $count == "0" ]
		then
		echo $count
		/usr/local/m1905/php/sbin/php-fpm -R
	fi
	sleep 10
done
