#!/bin/bash

[ $UID -ne 0 ]&& echo "Please run this script as root!"&& exit 1
if [ ! -d /usr/local/redis ];
then
	yum -y install gcc gcc-c++ libstdc++-devel
	wget http://download.vaststar.net/redis.zip -P /usr/local/src/
	cd /usr/local/src/
	unzip -o redis.zip
	tar -zxvf redis-5.0.4.tar.gz
	cd /usr/local/src/redis-5.0.4
	make
	make install PREFIX=/usr/local/redis
	mkdir -p /usr/local/redis/etc/
	cp /usr/local/src/redis.conf /usr/local/redis/etc/

	cd /usr/local/redis/bin/
	cp redis-benchmark redis-cli redis-server /usr/bin/

	cp /usr/local/src/redis-server.service /usr/lib/systemd/system/
	systemctl daemon-reload
	systemctl start redis-server
	systemctl enable redis-server
else
	echo "Redis has already been installed!"
fi

#systemctl stop nginx
#cd /KiosoftApplications/ServerApps/TTI_ReportServer/
#docker-compose stop
#docker rm $(docker ps -a -q)
#
#now=`date "+%Y%m%d"`
#mkdir -p /back/mysql/bak-$now
#mysqldump -ukiosoft -p123456 laundry > /back/mysql/bak-$now/laundry.sql
#ls /back/mysql/bak-$now/
#
#rm /root/$0
