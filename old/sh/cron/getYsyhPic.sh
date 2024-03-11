#!/bin/bash
# 上传数据
PATH=/bin:/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

ls /var/www/ | grep cs$ | while read houtai
do
	/usr/local/travelink/php/bin/php /var/www/$houtai/getYsyhPic.php
done
