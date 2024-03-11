#!/bin/bash
#2023-08-24
#lucaszhang@techtrex.com

if [ ! -d /usr/local/mysql ];
then	
	find -H /etc/ | grep my.c 
	rm -rf /etc/my.cnf /etc/my.cnf.d/
	rpm -qa|grep mariadb*
	rpm -e  mariadb-libs-* --nodeps

	yum -y install libaio expect libaio-devel bison bison-devel zlib-devel openssl openssl-devel ncurses ncurses-devel libcurl-devel libarchive-devel boost boost-devel  gcc gcc-c++ make perl kernel-headers kernel-devel pcre-devel unzip

	groupadd -r mysql
	useradd -r -g mysql -s /sbin/nologin -d /usr/local/mysql  -M mysql
	[ ! -d "/data" ] && mkdir /data
	chown -R mysql:mysql /data
	echo "export PATH=\$PATH:/usr/local/mysql/bin" >> ~/.bashrc
    source ~/.bashrc
	
	wget -P /usr/local/src/ https://download.vaststar.net/linux/mariadb-10.3.37.zip
	cd /usr/local/src/
	unzip mariadb-10.3.37.zip
	mv mysql /usr/local/
	
	mv /usr/local/mysql/mysql.service /etc/systemd/system/
	systemctl daemon-reload
	systemctl start mysql
	systemctl enable mysql
fi