#!/bin/bash

#升级后台

curl --connect-timeout  5  http://127.0.0.1/Organ/Cron/getInfo > /root/version.txt
version=`cat version.txt |awk -F ""\" '{print $4}'|cut -b 2-`
if [ "$version" != "1.3.3" ]
then
        if [ "$version" == "1.3.3.1" ]
        then
                echo "后台版本$version,已是最新版本，无需升级"
                exit 1
        fi
        echo "当前版本为不是最新,请先升级到1.3.3版本,再进行本次升级！"
        exit 1
fi
echo "start updateing ...."

wget http://219.146.255.198:8098/share/ftx/1.3/1.3.3.1/update/hotel_update_1.3.3.1_20190116.x86_64.rpm
rpm -e Hotel_update-1.3.3-0.x86_64
rpm  -Uvh  hotel_update_1.3.3.1_20190116.x86_64.rpm
if [ $? -eq 0 ];then
	rm -rf hotel_update_1.3.3.1_20190116.x86_64.rpm
else
	echo "update failed！"
	exit 1
fi
	
#升级apk
wget -P /root/ http://219.146.255.198:8098/share/ftx/1.3/1.3.3.1/apk/ftx_1.3.3.1_20190115.apk
ls /var/www|grep 'cs$'|while read line
do
        cat /var/www/$line/admin/template/admin/login.html | grep -q 8888
        if [ $? -eq 0 ];then
                cp /root/ftx_1.3.3.1_20190115.apk /var/www/share/hvupdate/
                mysql -uroot -p123456 $line -e 'update h_apk set apk_code=apk_code+1,apk_name="ftx_1.3.3.1_20190115.apk" where apk_package="com.micro.player"'
        else
                cp /root/ftx_1.3.3.1_20190115.apk /var/www/$line/admin/images/apk/
                mysql -uroot -p123456 $line -e 'update h_apk set apk_code=apk_code+1,apk_name="images/\apk/\ftx_1.3.3.1_20190115.apk",md5="d64ae88617b2b2587f41246c06734df1" where apk_package="com.micro.player"'
        fi
done
rm -rfv /root/ftx_1.3.3.1_20190115.apk
curl --connect-timeout  5  http://127.0.0.1/Organ/Cron/getInfo

