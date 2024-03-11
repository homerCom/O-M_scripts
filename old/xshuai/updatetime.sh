#!/bin/bash


wget -P /root/ http://219.146.255.198:8098/share/zhang/softwares/1Public/DatetimeUfo_628_V10_1.apk
wget -P /root http://219.146.255.198:8098/share/zhang/files/addVersion.php.1
mv /root/addVersion.php.1 /root/addVersion.php
ls /var/www|grep 'cs$'|while read line
do	
	dbUser=`awk -F "'" '/DB_USER/{print $4}' /var/www/$line/config.php`
    dbPassword=`awk -F "'" '/DB_PWD/{print $4}' /var/www/$line/config.php`
	cp /root/addVersion.php /var/www/$line/
	cat /var/www/$line/admin/template/admin/login.html | grep -q 8888
        if [ $? -eq 0 ];then
                cp /root/DatetimeUfo_628_V10_1.apk /var/www/share/hvupdate/
				mysql -u$dbUser -p$dbPassword $line -e 'update h_apk set apk_name="DatetimeUfo_628_V10_1.apk",apk_code = apk_code+1 where apk_package="com.xshuai.timeufo"'
        else
                cp /root/DatetimeUfo_628_V10_1.apk /var/www/$line/admin/images/apk/
				mysql -u$dbUser -p$dbPassword $line -e 'update h_apk set apk_name="images/apk/DatetimeUfo_628_V10_1.apk",apk_code = apk_code+1,md5="311fecb592914c839144973736fe7bd0" where apk_package="com.xshuai.timeufo"'
        fi
	cat /var/www/$line/VERSION
done
rm -rfv /root/DatetimeUfo_628_V10_1.apk
rm -rvf $0
ls /var/www|grep 'cs$'
