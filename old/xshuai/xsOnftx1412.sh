#!/bin/bash
# 风霆迅1.4.1系统（CentOS7）全新安装hclient

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 1 ]&&echo "参数不正确"&&exit 1
cat /etc/redhat-release  | grep -q "7.3"
[ $? -ne 0 ]&&echo "非ftx1.4.1系统"&&exit 1

HotelKey=$1

# 变量
xsvpn=`ip a | awk '/10\.8\./{print $2}'`

#yum更新
mkdir /etc/yum.repos.bak
mv /etc/yum.repos.d/* /etc/yum.repos.bak
wget http://mirrors.aliyun.com/repo/Centos-7.repo -O /etc/yum.repos.d/Centos-7.repo
wget http://mirrors.163.com/.help/CentOS7-Base-163.repo -O /etc/yum.repos.d/CentOS7-Base-163.repo
yum clean all && yum makecache
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum clean all && yum makecache

# rsync
echo haier123 > /etc/rsync.password&&chmod 600 /etc/rsync.password

# iptables
wget http://219.146.255.198:8233/salt/config/ftx/iptables.ftx1.4.1.el7 -O /etc/sysconfig/iptables
chmod 600 /etc/sysconfig/iptables
service iptables restart

# 创建相关目录
mkdir /tmp/xs
mkdir -p /usr/local/xiaoshuai
mkdir /home/hclient
ln -s /home/hclient /hclient
mkdir -p /hclient/resources/static

# jdk
cd /tmp/xs
wget -c http://219.146.255.198:8233/salt/software/jdk-8u121-linux-x64.tar.gz
tar -zxvf jdk-8u121-linux-x64.tar.gz  -C /usr/local/xiaoshuai/
mv /usr/local/xiaoshuai/jdk1.8.0_121/ /usr/local/xiaoshuai/jdk

echo '
export JAVA_HOME=/usr/local/xiaoshuai/jdk
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib;
export PATH=${JAVA_HOME}/bin:$PATH'>>~/.bashrc
source ~/.bashrc

# tomcat
cd /tmp/xs
wget -c http://219.146.255.198:8233/salt/software/apache-tomcat-8.0.43.tar.gz?v=123 -O /tmp/xs/apache-tomcat-8.0.43.tar.gz
tar -zxvf /tmp/xs/apache-tomcat-8.0.43.tar.gz -C /usr/local/xiaoshuai/
mv /usr/local/xiaoshuai/apache-tomcat-8.0.43  /usr/local/xiaoshuai/tomcat
wget http://219.146.255.198:8233/salt/config/xsnew/server.xml -O /usr/local/xiaoshuai/tomcat/conf/server.xml

# tomcat daemon
cd /usr/local/xiaoshuai/tomcat/bin
tar -zxvf commons-daemon-native.tar.gz
cd /usr/local/xiaoshuai/tomcat/bin/commons-daemon-1.0.15-native-src/unix
./configure --with-java=/usr/local/xiaoshuai/jdk
make
cp -f jsvc /usr/local/xiaoshuai/tomcat/bin/
useradd -M tomcat -s /sbin/nologin
chown -R tomcat /usr/local/xiaoshuai/tomcat
chmod 777 /usr/local/xiaoshuai/tomcat/bin/daemon.sh
wget http://219.146.255.198:8233/salt/config/xsnew/tomcat.service -O /usr/lib/systemd/system/tomcat.service
systemctl daemon-reload
systemctl enable tomcat.service
chown -R tomcat:tomcat /hclient/

# hclient程序
echo "HotelKey=$HotelKey" > /usr/h_config.properties
cd /tmp/xs/
wget -c http://219.146.255.198:8233/salt/base/xsnew/hclient.war -O /usr/local/xiaoshuai/tomcat/webapps/hclient.war
wget -c http://219.146.255.198:8233/salt/base/xsnew/hclient.sql -O /usr/local/xiaoshuai/tomcat/webapps/hclient.sql

# mysql
ln -s /dev/shm/mysql.sock /var/lib/mysql/mysql.sock
mysql -uroot -p123456 -e "set old_passwords=0;grant all privileges on *.* to 'xiaoshuai'@'localhost' identified by 'xshuai2015' with grant option;"
mysql -uxiaoshuai -pxshuai2015 -e "create database hclient;"
mysql -uxiaoshuai -pxshuai2015 hclient < /usr/local/xiaoshuai/tomcat/webapps/hclient.sql

sleep 1
systemctl start tomcat.service
printf "%-60s%s\n" "xiaoshuai tomcat" "[OK]"
sleep 1

# salt
echo "saltstack start"
wget http://219.146.255.198:8233/salt/software/salt-repo-2017.7-1.el7.noarch.rpm
rpm -ivh salt-repo-2017.7-1.el7.noarch.rpm
sed -i 's/https:\/\/repo.saltstack.com/http:\/\/mirrors.aliyun.com\/saltstack/g' /etc/yum.repos.d/salt-2017.7.repo
yum clean expire-cache
yum install -y salt-minion
rm -rf /etc/yum.repos.d/salt-2017.7.repo
sleep 2

sed -i '/#master:/cmaster: 10.8.0.170' /etc/salt/minion
sed -i '/default_include/s/^#//g' /etc/salt/minion
sed -i "/^#id/c id: $xsvpn" /etc/salt/minion

# salt mysql支持
pip2.7 install PyMySQL xlrd requests dmidecode netifaces
wget http://update.xshuai.com:8233/salt/config/iqiyi/mysql.conf -O /etc/salt/minion.d/mysql.conf

systemctl start salt-minion.service
sleep 1
systemctl enable salt-minion.service

# zabbix
wget http://219.146.255.198:8233/salt/software/zabbix-release-3.4-2.el7.noarch.rpm
rpm -ivh zabbix-release-3.4-2.el7.noarch.rpm
sed -i 's/http:\/\/repo.zabbix.com/https:\/\/mirrors.aliyun.com\/zabbix/g' /etc/yum.repos.d/zabbix.repo
yum install -y zabbix-agent
rm -rf /etc/yum.repos.d/zabbix.repo
wget http://219.146.255.198:8233/salt/config/iqiyi/zabbix_agentd.conf -O /etc/zabbix/zabbix_agentd.conf
wget http://219.146.255.198:8233/salt/config/iqiyi/zabbix_xs.conf.j2 -O /etc/zabbix/zabbix_agentd.d/zabbix_xs.conf
sed -i "/^Hostname=/cHostname=$xsvpn" /etc/zabbix/zabbix_agentd.d/zabbix_xs.conf
sed -i "/^ListenIP=/cListenIP=$xsvpn" /etc/zabbix/zabbix_agentd.d/zabbix_xs.conf
systemctl start zabbix-agent.service
sleep 1
systemctl enable zabbix-agent.service

# filebeat
cd /tmp/xs
wget -c http://219.146.255.198:8098/share/software/filebeat-6.8.1-linux-x86_64.tar.gz
tar -xzvf filebeat-6.8.1-linux-x86_64.tar.gz -C /usr/local/xiaoshuai/
mv /usr/local/xiaoshuai/filebeat-6.8.1-linux-x86_64 /usr/local/xiaoshuai/filebeat
wget http://219.146.255.198:8233/salt/config/elk/filebeat/filebeat.yml.j2 -O /usr/local/xiaoshuai/filebeat/filebeat.yml
xsvpn=`ip a | awk '/10\.8\./{print $2}'`
sed -i "/name/cname: $xsvpn" /usr/local/xiaoshuai/filebeat/filebeat.yml
wget http://219.146.255.198:8233/salt/config/elk/filebeat/filebeat.sh -O /usr/local/xiaoshuai/filebeat/filebeat.sh
chmod 777 /usr/local/xiaoshuai/filebeat/filebeat.sh
wget http://219.146.255.198:8233/salt/config/elk/filebeat/filebeat.service -O /usr/lib/systemd/system/filebeat.service
systemctl enable filebeat.service
sleep 1
systemctl start filebeat.service
printf "%-60s%s\n" "xiaoshuai filebeat" "[OK]"
sleep 1

# other software
yum -y install iotop curl dmidecode dos2unix fping ftp iftop lsof man nano ncftp nmap ntfs-3g python-devel.x86_64 python-pip sysstat tcpdump

# hclientsh
echo
rsync -avL xiaoshuai@10.8.0.170::hclientsh/ /usr/local/xiaoshuai/sh/ --password-file=/etc/rsync.password
printf "%-60s%s\n" "hclientsh" "[OK]"
sleep 2

# cron
curl http://219.146.255.198:8233/salt/config/xsnew/cron > /etc/cron.d/xsnew
echo "cron done"
rm -rfv *

#ansible
if [ ! -d /root/.ssh ];then
        mkdir -p /root/.ssh
fi
wget http://219.146.255.198:8233/salt/config/xs/id_rsa_252.pub
cat id_rsa_252.pub >> /root/.ssh/authorized_keys
iptables -I INPUT 5 -s 10.8.0.166 -p tcp -m tcp --dport 22 -j ACCEPT&&service iptables save

wget http://219.146.255.198:8233/salt/config/xs/id_rsa_233.pub
cat id_rsa_233.pub >> /root/.ssh/authorized_keys
iptables -I INPUT 5 -s 10.8.0.170 -p tcp -m tcp --dport 22 -j ACCEPT

service iptables save
rm -rf id_rsa_252.pub id_rsa_233.pub

echo
echo "1.拷贝212/home/hclient 到 本机，scp -r 192.168.1.212:/home/hclient/ ."
echo "2.chown -R tomcat:tomcat /home/hclient"
