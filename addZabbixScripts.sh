#!/bin/bash
# date:20220407
# author:lucaszhang@techtrex.com

[ $UID -ne 0 ]&&echo "Please run this script as root user"&&exit 1

storage='45.136.15.15'

#install python3 and Library
wget -P /usr/local/src/ https://www.python.org/ftp/python/3.7.13/Python-3.7.13.tar.xz
cd /usr/local/src/
tar -xvf Python-3.7.13.tar.xz
cd Python-3.7.13
./configure --prefix=/usr/local/python3
make
make install
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
/usr/bin/pip3 install simplejson
/usr/bin/pip3 install "docker==4.4.4"

#get scripts
mkdir -pv /usr/local/zabbix_agentd/alertscripts/
wget -P /usr/local/zabbix_agentd/alertscripts/ http://$storage/sh/docker_monitor.py
wget -P /usr/local/zabbix_agentd/alertscripts/ http://$storage/sh/docker_discovery.py
chmod +x /usr/local/zabbix_agentd/alertscripts/*
chown -R zabbix:zabbix /usr/local/zabbix_agentd/alertscripts/
sed -i '264a UserParameter=docker_status[*],sudo /usr/bin/python3 /usr/local/zabbix_agentd/alertscripts/docker_monitor.py $1 $2' /usr/local/zabbix_agentd/conf/zabbix_agentd.conf
sed -i '264a UserParameter=docker_discovery,sudo /usr/bin/python3 /usr/local/zabbix_agentd/alertscripts/docker_discovery.py' /usr/local/zabbix_agentd/conf/zabbix_agentd.conf
service zabbix_agentd restart
#visudo
#	zabbix ALL=NOPASSWD: ALL

#add permission for zabbix
sed -i '100a zabbix ALL=NOPASSWD: ALL' /etc/sudoers

#remove the shell
/bin/rm /root/$0
