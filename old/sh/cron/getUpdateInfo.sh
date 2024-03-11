#!/bin/bash
# 上传数据
PATH=/bin:/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

ls /var/www/ | grep cs$ | while read houtai
do
	grep -q 8888 /var/www/$houtai/admin/template/admin/login.html
	if [ $? -ne 0 ];then
		if [ -f /etc/redhat-release ];then
			flock -xn /tmp/getUpdateInfo.lock -c "/usr/local/travelink/php/bin/php /var/www/$houtai/getUpdateInfo.php >> /var/www/$houtai/getUpdateInfo.log"
		else
			flock -xn /tmp/getUpdateInfo.lock -c "/usr/bin/php /var/www/$houtai/getUpdateInfo.php >> /var/www/$houtai/getUpdateInfo.log"
		fi
	fi
done
