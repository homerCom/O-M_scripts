#!/bin/bash 
#author:lucaszhang@techtrex.com
#date:2022.07.07

[ $UID -ne 0 ]&&echo "Please run this script as root user"&&exit 1

#install node_exporter
if [ ! -d /usr/local/node_exporter ];then
	wget -P /usr/local/src/ http://download.vaststar.net/node_exporter.zip --no-check-certificate
	unzip -d /usr/local/ /usr/local/src/node_exporter.zip
	mv /usr/local/node_exporter/node_exporter.service /etc/systemd/system/
	systemctl start node_exporter
	systemctl enable node_exporter
else
	echo "node_exporter exists!!!"
fi

#myqld exporter
if [ ! -d /usr/local/mysqld_exporter ];then
	wget http://download.vaststar.net/mysqld_exporter.zip -P /usr/local/src/ --no-check-certificate
	unzip -d /usr/local/ /usr/local/src/mysqld_exporter.zip
	mv /usr/local/mysqld_exporter/mysqld_exporter.service /etc/systemd/system/
	systemctl start mysqld_exporter
	systemctl enable mysqld_exporter
else
	echo "mysql_exporter exists!!!"
fi

#blackbox exporter
if [ ! -d /usr/local/blackbox_exporter ];then
	wget http://download.vaststar.net/blackbox_exporter.zip -P /usr/local/src/ --no-check-certificate
	unzip /usr/local/src/blackbox_exporter.zip -d /usr/local/
	mv /usr/local/blackbox_exporter/blackbox_exporter.service /etc/systemd/system/
	chmod +x /usr/local/blackbox_exporter/blackbox_exporter
	systemctl start blackbox_exporter
	systemctl enable blackbox_exporter
else
	echo "blackbox_exporter exists!!!"
fi

#php-fpm exporter
if [ ! -d /usr/local/php-fpm_exporter ];then
	wget http://download.vaststar.net/php-fpm_exporter.zip -P /usr/local/src/ --no-check-certificate
	unzip /usr/local/src/php-fpm_exporter.zip -d /usr/local/
	mv /usr/local/php-fpm_exporter/php-fpm_exporter.service /etc/systemd/system/
	systemctl start php-fpm_exporter
	systemctl enable php-fpm_exporter
else
	echo "php-fpm_exporter exists!!!"
fi

#redis exporter service配置文件需要修改
if [ ! -d /usr/local/redis_exporter ];then
	wget http://download.vaststar.net/redis_exporter.zip -P /usr/local/src/ --no-check-certificate
	unzip /usr/local/src/redis_exporter.zip -d /usr/local/
	mv /usr/local/redis_exporter/redis_exporter.service /etc/systemd/system/
	systemctl start redis_exporter
	systemctl enable redis_exporter
else
	echo "redis_exporter exists!!!"
fi

#docker exporter
docker run   --volume=/:/rootfs:ro --volume=/var/run:/var/run:ro --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --volume=/dev/disk/:/dev/disk:ro --publish=8080:8080 --detach=true --name=cadvisor --restart=always google/cadvisor:latest

netstat -nap|grep exporter
#rm $0