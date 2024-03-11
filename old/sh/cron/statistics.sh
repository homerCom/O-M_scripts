#!/bin/bash
# 上传数据
PATH=/bin:/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

ls /var/www/ | grep cs$ | while read houtai
do
	if [ -f /etc/redhat-release ];then
		/usr/local/travelink/php/bin/php /var/www/$houtai/statistics.php
	else
		/usr/bin/php /var/www/$houtai/statistics.php
	fi
done
