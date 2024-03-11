#!/bin/bash
#date:20221104
#function:install redis-6.2.7

[ $UID -ne 0 ]&& echo "Please run this script as root!"

result=`redis-server -v|grep "6.2.7"`
if [[ "$result" = "" ]]
then
	
	#ps -ef|grep redis|grep -v grep|awk '{print $2}'|xargs kill -s 9
	mv /usr/local/redis /back/
	if [ -f /etc/init.d/redis ];then
		mv /etc/init.d/redis /back/
	fi
	
	wget http://download.vaststar.net/redis6.2.7.zip -P /usr/local/src/
	cd /usr/local/src/
	unzip -o redis6.2.7.zip
	
	tar -zxvf redis-6.2.7.tar.gz
	cd /usr/local/src/redis-6.2.7
	make
	make install PREFIX=/usr/local/redis
	mkdir -p /usr/local/redis/etc/
	cp /usr/local/src/redis.conf /usr/local/redis/etc/

	cd /usr/local/redis/bin/
	cp redis-benchmark redis-cli redis-server /usr/bin/

	mv /usr/local/src/redis.service /etc/systemd/system/
	systemctl daemon-reload
	systemctl start redis.service
	systemctl enable redis.service
	
	rm -rf /usr/local/src/redis-6.2.7
	rm -rf /usr/local/src/redis6.2.7.zip
else
	echo "Redis 6.2.7 has already been installed!"
fi

