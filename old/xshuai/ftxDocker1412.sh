#!/bin/bash

#系统版本检测
cat /etc/redhat-release  | grep -q "7.6"
[ $? -ne 0 ]&&echo "NOT CentOS7.6,please check!"&&exit 1

for eth in `ip addr | grep -i broadcast | awk '{ print $2 }' | awk -F ':' '{print $1}'|grep -v docker|grep -v veth`
do
if [ `ethtool $eth|grep detected|grep yes|wc -l`  -eq 1 ];then
    ethn=$eth
fi
done

echo '------------------------------------------------------------------------------'
echo "请输入IP地址 eg: 192.168.1.100 | Please enter the IP address eg: 192.168.1.100"
read -e IPADDR
echo '---------------------------------------------------------------------------------'
echo "请输入子网掩码 eg: 255.255.255.0 | Please enter the subnet mask eg: 255.255.255.0"
read -e NETMASK
echo '---------------------------------------------------------------------'
echo "请输入网关 eg: 192.168.1.1 | Please enter the gateway eg: 192.168.1.1"
read -e GATEWAY

echo "DEVICE=$ethn
BOOTPROTO=static
ONBOOT=yes
IPADDR=$IPADDR
GATEWAY=$GATEWAY
NETMASK=$NETMASK
DNS1=114.114.114.114
DNS2=8.8.8.8"> /etc/sysconfig/network-scripts/ifcfg-$ethn
service network restart

#修改容器内电影配置文件
if [ ! -f "/root/config.php" ];then
    docker cp ftxjoy:/data/html/micro/Application/Common/Conf/config.php /root/
else
    mv /root/config.php /root/config.php.bak
    docker cp ftxjoy:/data/html/micro/Application/Common/Conf/config.php /root/
fi
sed -i "s/'VIDEO_HOST' => '.*'/'VIDEO_HOST' => 'http:\/\/$IPADDR:8080'/" /root/config.php
#docker exec -it ftxjoy rm -rf /data/html/micro/Application/Common/Conf/config.php
docker cp /root/config.php ftxjoy:/data/html/micro/Application/Common/Conf/
rm -rf /root/config.php

/usr/bin/pkill dhclient

#网络测试
echo 'Testing network...'
ping baidu.com -c 3 2>/dev/null
[ $? -ne 0 ]&&echo "Network is disconnected，please check!"&&exit 1

#yum更新
if [ ! -f /etc/yum.repos.d/CentOS-Base.repo.backup ];
then
	mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
	yum clean all
	yum makecache
fi

#小帅vpn
line=`ip a|grep 10.8|wc -l`
if [ $line == 0 ];then
        echo '请输入小帅 key... | Please input xiaoshuai key...'
        read -e KEY
        yum install -y epel-release
        yum install openvpn -y
        wget http://120.26.231.165/securehotel/client_xs$KEY.tar.gz
        groupadd nogroup
        tar -xzvf client_xs$KEY.tar.gz -C /etc/openvpn/
        systemctl start openvpn@client_xsnew.service
        systemctl enable openvpn@client_xsnew.service
        sleep 5
        rm -rf client_xs$KEY.tar.gz
else
        echo "Xiaoshuai's key already been set，Nothing to do!"
fi

#VPN测试
echo 'Testing VPN...'
ping 10.8.0.1 -c 3 2>/dev/null
[ $? -ne 0 ]&&echo "VPN is diconnected，please check!"&&exit 1

#系统配置
if [ ! -d "/video" ];
then
	mkdir /video
	if [ ! -b /dev/sdb ] && [ ! -b /dev/sdc ];then
		umount /home
		lvrename /dev/centos/home /dev/centos/video
		sed -i 's/home/video/g' /etc/fstab
		mount -a
		echo "lvm disk home change to video ok!"
	fi
	if [ -b /dev/md126 ];then
			parted /dev/md126 << FORMAT
			mklabel gpt
			mkpart primary 0 -1
			quit
FORMAT

			mkfs.ext4 /dev/md126p1

			uuid=`blkid |grep /dev/md126p1 |awk -F '"' '{print $2}'`
			sed -i "11i UUID=$uuid /video                   ext4     defaults        0 0" /etc/fstab
			mount -a
			mkdir -p /video/micro_ticket
	fi
	
	#关闭selinux
	sed -i /SELINUX=enforcing/s/enforcing/disabled/g /etc/selinux/config
	
	#关闭Networkmanage
	systemctl stop NetworkManager 
	systemctl disable NetworkManager 
	
	#系统优化
	echo -e "*\tsoft\tnofile\t65535\n*\thard\tnofile\t65535" > /etc/security/limits.conf
	grep -q pam_limits /etc/pam.d/login || echo "session required /lib64/security/pam_limits.so" >> /etc/pam.d/login
	echo -e "net.ipv4.ip_forward = 1\nkernel.pid_max=65536 " > /etc/sysctl.conf
	echo -e "net.ipv4.ip_local_port_range = 32768 59001 " > /etc/sysctl.conf
	sysctl -p
	
	#防火墙
	systemctl stop firewalld.service
	systemctl disable firewalld
	yum install -y iptables-services
	wget http://update.xshuai.com:8098/share/zhang/files/ftx/iptables.ftx.docker -O /etc/sysconfig/iptables
	chmod 600 /etc/sysconfig/iptables
	systemctl enable iptables.service
	systemctl restart iptables.service
fi

#小帅环境安装
if [ ! -d /home/hclient ] || [ ! -d /usr/local/xiaoshuai/tomcat ];
then
	HotelKey=test
	xsvpn=`ip a | awk '/10\.8\./{print $2}'`
	# rsync
	echo haier123 > /etc/rsync.password&&chmod 600 /etc/rsync.password
	
	# mysql
	echo "MariaDB start"
	yum -y install mariadb-server mariadb
	systemctl start mariadb.service
	systemctl enable mariadb.service
	mysqladmin -u root password "xshuai2015"
	
	# 创建相关目录
	mkdir /tmp/xs
	mkdir -p /usr/local/xiaoshuai
	mkdir /home/hclient
	ln -s /home/hclient /hclient
	mkdir -p /hclient/resources/static
	
	# jdk
	cd /tmp/xs
	wget -c http://update.xshuai.com:8233/salt/software/jdk-8u121-linux-x64.tar.gz
	tar -zxvf jdk-8u121-linux-x64.tar.gz  -C /usr/local/xiaoshuai/
	mv /usr/local/xiaoshuai/jdk1.8.0_121/ /usr/local/xiaoshuai/jdk

	#echo '
	#export JAVA_HOME=/usr/local/xiaoshuai/jdk
	#export JRE_HOME=${JAVA_HOME}/jre
	#export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib;
	#export PATH=${JAVA_HOME}/bin:$PATH'>>~/.bashrc
	#source ~/.bashrc
	
	# tomcat
	cd /tmp/xs
	wget -c http://update.xshuai.com:8033/salt/software/apache-tomcat-8.0.43.tar.gz?v=123 -O /tmp/xs/apache-tomcat-8.0.43.tar.gz
	tar -zxvf /tmp/xs/apache-tomcat-8.0.43.tar.gz -C /usr/local/xiaoshuai/
	mv /usr/local/xiaoshuai/apache-tomcat-8.0.43  /usr/local/xiaoshuai/tomcat
	wget http://update.xshuai.com:8098/share/zhang/files/tomcat/server.xml -O /usr/local/xiaoshuai/tomcat/conf/server.xml
	wget http://update.xshuai.com:8098/share/zhang/files/tomcat/catalina.sh.j2 -O /usr/local/xiaoshuai/tomcat/bin/catalina.sh
	sed -i "/grains/c-Djava.rmi.server.hostname=$xsvpn" /usr/local/xiaoshuai/tomcat/bin/catalina.sh
	wget http://update.xshuai.com:8098/share/zhang/files/tomcat/xsjmxremote.access -O /usr/local/xiaoshuai/jdk/jre/lib/management/xsjmxremote.access
	wget http://update.xshuai.com:8098/share/zhang/files/tomcat/xsjmxremote.password -O /usr/local/xiaoshuai/jdk/jre/lib/management/xsjmxremote.password
	chown tomcat:root /usr/local/xiaoshuai/jdk/jre/lib/management/xsjmxremote.access /usr/local/xiaoshuai/jdk/jre/lib/management/xsjmxremote.password
	chmod 600 /usr/local/xiaoshuai/jdk/jre/lib/management/xsjmxremote.password
	
	# tomcat daemon
	useradd -M tomcat -s /sbin/nologin
	chown -R tomcat /usr/local/xiaoshuai/tomcat
	wget http://update.xshuai.com:8098/share/zhang/files/tomcat/tomcat.service -O /usr/lib/systemd/system/tomcat.service
	systemctl daemon-reload
	systemctl enable tomcat.service
	chown -R tomcat:tomcat /hclient/

	# hclient程序
	echo "HotelKey=$HotelKey" > /usr/h_config.properties
	cd /tmp/xs/
	wget -c http://update.xshuai.com:8098/share/zhang/files/tomcat/hclient.war -O /usr/local/xiaoshuai/tomcat/webapps/hclient.war
	wget -c http://update.xshuai.com:8098/share/zhang/files/tomcat/hclient.sql -O /usr/local/xiaoshuai/tomcat/webapps/hclient.sql
	
	# mysql
	mysql -uroot -pxshuai2015 -e "set old_passwords=0;grant all privileges on *.* to 'xiaoshuai'@'localhost' identified by 'xshuai2015' with grant option;"
	mysql -uxiaoshuai -pxshuai2015 -e "create database hclient;"
	mysql -uxiaoshuai -pxshuai2015 hclient < /usr/local/xiaoshuai/tomcat/webapps/hclient.sql

	sleep 1
	systemctl start tomcat.service
	printf "%-60s%s\n" "xiaoshuai tomcat" "[OK]"
	sleep 1
	
	# filebeat
	cd /tmp/xs
	wget -c http://update.xshuai.com:8098/share/software/filebeat-6.8.1-linux-x86_64.tar.gz
	tar -xzvf filebeat-6.8.1-linux-x86_64.tar.gz -C /usr/local/xiaoshuai/
	mv /usr/local/xiaoshuai/filebeat-6.8.1-linux-x86_64 /usr/local/xiaoshuai/filebeat
	wget http://update.xshuai.com:8233/salt/config/elk/filebeat/filebeat.yml.j2 -O /usr/local/xiaoshuai/filebeat/filebeat.yml
	xsvpn=`ip a | awk '/10\.8\./{print $2}'`
	sed -i "/name/cname: $xsvpn" /usr/local/xiaoshuai/filebeat/filebeat.yml
	wget http://update.xshuai.com:8233/salt/config/elk/filebeat/filebeat.sh -O /usr/local/xiaoshuai/filebeat/filebeat.sh
	chmod 777 /usr/local/xiaoshuai/filebeat/filebeat.sh
	wget http://update.xshuai.com:8233/salt/config/elk/filebeat/filebeat.service -O /usr/lib/systemd/system/filebeat.service
	systemctl enable filebeat.service
	sleep 1
	systemctl start filebeat.service
	printf "%-60s%s\n" "xiaoshuai filebeat" "[OK]"
	
	# salt
	echo "saltstack start"
	wget http://update.xshuai.com:8233/salt/software/salt-repo-2017.7-1.el7.noarch.rpm
	rpm -ivh salt-repo-2017.7-1.el7.noarch.rpm
	sed -i 's/https:\/\/repo.saltstack.com/http:\/\/mirrors.aliyun.com\/saltstack/g' /etc/yum.repos.d/salt-2017.7.repo
	rm -rf /etc/yum.repos.d/salt-2017.7.repo
	yum clean expire-cache
	yum install -y salt-minion
	rm -rf /etc/yum.repos.d/salt-2017.7.repo
	sleep 2

	sed -i '/#master:/cmaster: 10.8.0.170' /etc/salt/minion
	sed -i '/default_include/s/^#//g' /etc/salt/minion
	sed -i "/^#id/c id: $xsvpn" /etc/salt/minion

	# salt mysql支持
	pip2.7 install PyMySQL xlrd requests dmidecode netifaces docker
	wget http://update.xshuai.com:8233/salt/config/salt/mysql.conf.j2 -O /etc/salt/minion.d/mysql.conf
	sed -i "/user/cmysql.user: 'xiaoshuai'" /etc/salt/minion.d/mysql.conf
	sed -i "/pass/cmysql.pass: 'xshuai2015'" /etc/salt/minion.d/mysql.conf

	systemctl start salt-minion.service
	sleep 1
	systemctl enable salt-minion.service
	
	#ansible
	if [ ! -f /root/.ssh ];then
			mkdir -p /root/.ssh
	fi
	wget http://update.xshuai.com:8098/share/zhang/files/ansible/id_rsa_252.pub
	cat id_rsa_252.pub >> /root/.ssh/authorized_keys
	wget http://update.xshuai.com:8098/share/zhang/files/ansible/id_rsa_233.pub
	cat id_rsa_233.pub >> /root/.ssh/authorized_keys
	rm -rf id_rsa_252.pub id_rsa_233.pub
	
	# zabbix
	wget http://update.xshuai.com:8233/salt/software/zabbix-release-3.4-2.el7.noarch.rpm
	rpm -ivh zabbix-release-3.4-2.el7.noarch.rpm
	sed -i 's/http:\/\/repo.zabbix.com/https:\/\/mirrors.aliyun.com\/zabbix/g' /etc/yum.repos.d/zabbix.repo
	yum install -y zabbix-agent
	rm -rf /etc/yum.repos.d/zabbix.repo
	wget http://update.xshuai.com:8233/salt/config/zabbix/zabbix_agentd.conf -O /etc/zabbix/zabbix_agentd.conf
	wget http://update.xshuai.com:8233/salt/config/zabbix/zabbix_xs.conf.j2.ftx -O /etc/zabbix/zabbix_agentd.d/zabbix_xs.conf
	sed -i "/^Hostname=/cHostname=$xsvpn" /etc/zabbix/zabbix_agentd.d/zabbix_xs.conf
	sed -i "/^ListenIP=/cListenIP=$xsvpn" /etc/zabbix/zabbix_agentd.d/zabbix_xs.conf
	systemctl start zabbix-agent.service
	sleep 1
	systemctl enable zabbix-agent.service

	# adb
	echo 
	echo "start platform-tools"
	sleep 1
	cd /root/temp/res/
	wget http://update.xshuai.com:8098/share/zhang/files/adb/platform-tools.tar.gz
	tar -xzvf platform-tools.tar.gz
	mv -v ./platform-tools /usr/local/xiaoshuai/
	mv /usr/bin/adb /usr/bin/adb1
	ln -s /usr/local/xiaoshuai/platform-tools/adb /usr/bin/adb
	yum install libgcc_s.so.1 --setopt=protected_multilib=false -y
	yum install ld-linux.so.2 -y
	printf "%-60s%s\n" "xiaoshuai adb" "[OK]"
	sleep 1
	
	# other software
	yum -y install iotop lrzsz curl unzip net-tools dmidecode dos2unix fping ftp iftop lsof man nano ncftp nmap ntfs-3g python-devel.x86_64 python-pip rsync sysstat tcpdump vim

	# hclientsh
	echo
	rsync -avL xiaoshuai@10.8.0.170::hclientsh/ /usr/local/xiaoshuai/sh/ --password-file=/etc/rsync.password
	printf "%-60s%s\n" "xiaoshuai hclientsh" "[OK]"
	sleep 1

	# cron
	curl http://update.xshuai.com:8233/salt/config/xsnew/cron > /etc/cron.d/xsnew
	printf "%-60s%s\n" "xiaoshuai cron" "[OK]"
	sleep 1
	
fi
/usr/sbin/ifconfig
if [ ! -d /home/hclient ] || [ ! -d /usr/local/xiaoshuai/tomcat ];
then
	echo
	echo "1.拷贝212/home/hclient 到 本机，scp -r 192.168.1.212:/home/hclient/ ."
	echo "2.chown -R tomcat:tomcat /home/hclient"
fi
