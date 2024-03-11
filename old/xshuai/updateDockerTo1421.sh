#!/bin/bash
release=`cat /etc/redhat-release|awk '{print$4}'`
if [ $release = "7.6.1810" ];then
		echo "当前版本：$release     通过"
else
        echo "当前系统为docker版本，请手动升级！	未通过"
        exit
fi

#查询空间是否满足5G要求
space=`docker exec -it ftxjoy /usr/bin/df -lh|grep -w / |awk '{print int($(NF-2))}'`
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

docker exec -it ftxjoy /usr/bin/curl -s http://127.0.0.1/Organ/Cron/getInfo -o /tmp/version.txt
version=`docker exec -it ftxjoy /usr/bin/cat /tmp/version.txt|awk -F '"' '{print $4}'`
if [ $version != "V1.4.1.2" ];then
	echo "版本错误，请检查!		未通过"
	exit
else
	echo "电影系统版本$version    通过"	
fi

#安装rsync
docker exec -it ftxjoy /usr/bin/yum install -y rsync >/dev/null 2>&1

#升级1.4.2.1
docker exec -it ftxjoy /usr/bin/rpm -Uvh /video/ftx_1.4.2.1_2021061701.x86_64.rpm

#删除apk文件
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210527153033_2140016.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2020193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2030193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2040193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2070193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2080193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2090193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2100193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2120193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2160193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2180193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2190193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2200193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2210193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2220193.apk
docker exec -it ftxjoy /usr/bin/rm -rf /data/html/micro/Uploads/appdownload/hotel_1.4.2.1_20210616151622_2230193.apk

#升级后检测
/usr/bin/curl -s http://127.0.0.1/Organ/Cron/getInfo -o /tmp/version.txt
version=`/usr/bin/cat /tmp/version.txt|awk -F '"' '{print $4}'`
echo "当前版本:$version"
if [ $version == "V1.4.2.1" ];then
    echo "升级成功！"
else
    echo "升级失败！" 
fi
