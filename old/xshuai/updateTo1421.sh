#!/bin/bash
release=`cat /etc/redhat-release|awk '{print$4}'`
if [ $release = "7.6.1810" ];then
        echo "当前系统为docker版本，请手动升级！	未通过"
        exit
else
	echo "当前版本：$release     通过"
fi

#清理空间
find /data/logs/ -name 'dev-*' -mtime +4 | xargs rm -rf
find /opt -name '*.rpm'|xargs rm -rf
find /root -name '*.rpm'|xargs rm -rf
cat /dev/null >/var/log/access.log
cat /dev/null >/var/www/tlkcs/upgradeFeedback.txt
cat /dev/null >/data/mysql/$HOSTNAME-slow.log
rm -rf /data/html/micro/Uploads/appdownload/*
rm -rf /data/html/micro/Uploads/appdownload.bak/*

#查询空间是否满足5G要求
space=`df -lh|grep -w / |awk '{print int($(NF-2))}'`
if [ $space -lt 5 ];then
	echo "空间不足，清理空间后再试		未通过"
	exit
else
	echo "空间正常      通过"
fi

if [ ! -f /video/ftx_1.4.2.1_2021061701.x86_64.rpm ];then
	wget -P /video http://219.146.255.198:8098/share/ftx/1.4/1.4.2.1/ftx_1.4.2.1_2021061701.x86_64.rpm
fi

md5=`md5sum /video/ftx_1.4.2.1_2021061701.x86_64.rpm|awk '{print$1}'`
if [ $md5 != "c1c4e8fb196897e5bba0f495314f2fed" ];then
	echo "升级包错误，请重新下载！		未通过"
	exit
else
	echo "升级包检查完成    	通过"
fi

curl -s http://127.0.0.1/Organ/Cron/getInfo -o /tmp/version.txt
version=`cat /tmp/version.txt|awk -F '"' '{print $4}'`
if [ $version != "V1.4.1.2" ];then
	echo "版本错误，请检查!		未通过"
	exit
else
	echo "电影系统版本$version    通过"	
fi
rpm -Uvh /video/ftx_1.4.2.1_2021061701.x86_64.rpm

space=`df -lh|grep -w / |awk '{print $(NF-2)}'`
echo "当前剩余空间为：$space"
