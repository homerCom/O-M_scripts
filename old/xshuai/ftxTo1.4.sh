#!/bin/bash

#升级后台

curl --connect-timeout  5  http://127.0.0.1/Organ/Cron/getInfo > /root/version.txt
version=`cat /root/version.txt |awk -F ""\" '{print $4}'|cut -b 2-`

case $version in
	1.3.3 )
		echo $version
		#1.3.3 -> 1.3.3.1
		wget -P /root/ http://219.146.255.198:8098/share/ftx/1.3/1.3.3.1/update/ftx_1.3.3.1_20190116.x86_64.rpm
		rpm -e Hotel_update-1.3.3-0.x86_64
		rpm -Uvh /root/ftx_1.3.3.1_20190116.x86_64.rpm
		if [ $? -eq 0 ];then
        		rm -rf /root/ftx_1.3.3.1_20190116.x86_64.rpm
		else
        		echo "update failed！"
        		exit 1
		fi

		#1.3.3.1 -> 1.3.3.3
		wget -P /root/ http://219.146.255.198:8098/share/ftx/1.3/1.3.3.3/ftx_1.3.3.3_2019041503.x86_64.rpm
		rpm  -Uvh /root/ftx_1.3.3.3_2019041503.x86_64.rpm
                if [ $? -eq 0 ];then
                        rm -rf /root/ftx_1.3.3.3_2019041503.x86_64.rpm
                else
                        echo "update failed！"
                        exit 1
                fi
		
		#1.3.3.3 -> 1.4.0.0
	        wget -P /root/ http://219.146.255.198:8098/share/ftx/1.4/update/ftx_1.4.0.0_2019071703.x86_64.rpm
		rpm  -Uvh /root/ftx_1.4.0.0_2019071703.x86_64.rpm
                if [ $? -eq 0 ];then
                        rm -rf /root/ftx_1.4.0.0_2019071703.x86_64.rpm
                else
                        echo "update failed！"
                        exit 1
                fi
		;;
	1.3.3.1)
                #1.3.3.1 -> 1.3.3.3
                wget -P /root/ http://219.146.255.198:8098/share/ftx/1.3/1.3.3.3/ftx_1.3.3.3_2019041503.x86_64.rpm
                rpm  -Uvh /root/ftx_1.3.3.3_2019041503.x86_64.rpm
                if [ $? -eq 0 ];then
                        rm -rf /root/ftx_1.3.3.3_2019041503.x86_64.rpm
                else
                        echo "update failed！"
                        exit 1
                fi

                #1.3.3.3 -> 1.4.0.0
                wget -P /root/ http://219.146.255.198:8098/share/ftx/1.4/update/ftx_1.4.0.0_2019071703.x86_64.rpm
                rpm  -Uvh /root/ftx_1.4.0.0_2019071703.x86_64.rpm
                if [ $? -eq 0 ];then
                        rm -rf /root/ftx_1.4.0.0_2019071703.x86_64.rpm
                else
                        echo "update failed！"
                        exit 1
                fi
                ;;
	1.3.3.3)
		echo "$version版本，请手动更新！"
		exit 1
		;;
	1.4.0.0)
		echo "已是最新版本，无需更新！"
		exit 1
		;;
	*)
		echo "版本错误！"
		exit 1
		;;
esac

#添加小帅nginx配置
sed -i '$i include /var/www/conf/travelink.conf;' /usr/local/m1905/nginx/conf/nginx.conf
killall nginx
sleep 1
/usr/local/m1905/nginx/sbin/nginx
/usr/local/m1905/nginx_video/sbin/nginx

#升级apk
wget -P /root/ http://219.146.255.198:8098/share/ftx/1.4/apk/ftx_1.4.0.0_20190711.apk
ls /var/www|grep 'cs$'|while read line
do
        cat /var/www/$line/admin/template/admin/login.html | grep -q 8888
        if [ $? -eq 0 ];then
                cp /root/ftx_1.4.0.0_20190711.apk /var/www/share/hvupdate/
                mysql -uroot -p123456 $line -e 'update h_apk set apk_code=apk_code+1,apk_name="ftx_1.4.0.0_20190711.apk" where apk_package="com.micro.player"'
        else
                cp /root/ftx_1.4.0.0_20190711.apk /var/www/$line/admin/images/apk/
                mysql -uroot -p123456 $line -e 'update h_apk set apk_code=apk_code+1,apk_name="images/\apk/\ftx_1.4.0.0_20190711.apk",md5="27ada69cda6efa8bc7e5ba4c9fdda998" where apk_package="com.micro.player"'
        fi
	cat /var/www/$line/VERSION
done
rm -rf /root/ftx_1.4.0.0_20190711.apk
curl --connect-timeout  5  http://127.0.0.1/Organ/Cron/getInfo
