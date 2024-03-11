#!/bin/bash
# 格式：脚本名
# 功能：centos7部署系统

# before install
[ $UID -ne 0 ]&&echo "Run script as root!"&&exit 1
[ $PWD != /tmp/install ]&&echo "Put the script in /tmp/install/!"&&exit 1

key=`ls /tmp/install/| awk -F [_.] '/vpn/{print $2}'`
[ `curl -sI http://219.146.255.198:8098/release/$key.tar.gz | sed -n 1p | awk '{print $2}'` -ne 200 ]&&echo "key error"&&exit 1
[ `curl -sI http://219.146.255.198:8098/release/$key.txt | sed -n 1p | awk '{print $2}'` -ne 200 ]&&echo "keytxt error"&&exit 1

echo "start to download the package."
wget http://219.146.255.198:8098/release/$key.tar.gz
wget http://219.146.255.198:8098/release/$key.txt
htName=`cat /tmp/install/$key.txt | awk -F '-' '{print $1}'`
houtaiCode=`cat /tmp/install/$key.txt | awk -F '[-.]' '{print $7}'`

## 源
yum install -y wget
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
wget http://mirrors.163.com/.help/CentOS7-Base-163.repo -O /etc/yum.repos.d/Centos-Base.repo
yum clean all
yum makecache

# rsync
echo haier123 > /etc/rsync.password&&chmod 600 /etc/rsync.password

## other software
yum -y install axel curl dos2unix ftp iftop lrzsz lsof man nano nmap ntfs-3g openvpn rsync sysstat tcpdump vim wget

## vpnIP
vpnIP=`ip a | awk '/10\.8\./{print $2}'`

## nginx
echo "nginx start"
wget http://219.146.255.198:8098/share/software/nginx-release-centos-7-0.el7.ngx.noarch.rpm
rpm -ivh nginx-release-centos-7-0.el7.ngx.noarch.rpm
yum -y install nginx

wget http://219.146.255.198:8098/conf/default.conf -O /etc/nginx/conf.d/default.conf
wget http://219.146.255.198:8098/conf/nginx.conf -O /etc/nginx/nginx.conf
mkdir /var/www/
systemctl start nginx
systemctl enable nginx.service

## MariaDB
echo "MariaDB start"
yum -y install mariadb-server mariadb
systemctl start mariadb.service
systemctl enable mariadb.service
mysqladmin -u root password "travelink"

## php5.3
echo "php5.3 start"
yum -y install gcc bison bison-devel zlib-devel libmcrypt-devel mcrypt mhash-devel openssl-devel libxml2-devel libcurl-devel bzip2-devel \
readline-devel libedit-devel sqlite-devel libjpeg-devel libpng-devel freetype freetype-devel
groupadd www && useradd -g www -s /sbin/nologin -M www
wget http://219.146.255.198:8098/share/software/php-5.3.27.tar.gz
tar -xzvf php-5.3.27.tar.gz
cd /tmp/install/php-5.3.27
./configure \
--prefix=/usr/local/travelink/php \
--with-config-file-path=/usr/local/travelink/php/etc \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-iconv-dir \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-gd \
--with-zlib \
--with-libxml-dir \
--with-curl \
--with-openssl \
--with-mcrypt \
--with-xmlrpc \
--disable-ipv6 \
--enable-zip \
--enable-fpm \
--enable-mbstring \
--enable-soap \
--enable-bcmath \
--enable-pcntl \
--enable-sockets

make && make install

wget http://219.146.255.198:8098/conf/php.ini -O /usr/local/travelink/php/etc/php.ini
wget http://219.146.255.198:8098/conf/php-fpm.conf -O /usr/local/travelink/php/etc/php-fpm.conf
wget http://219.146.255.198:8098/conf/php-fpm -O /etc/init.d/php-fpm
ln -s /usr/local/travelink/php/bin/php /usr/bin/php
chmod 755 /etc/init.d/php-fpm
echo "/etc/init.d/php-fpm start" >> /etc/rc.local
chmod +x /etc/rc.d/rc.local
/etc/init.d/php-fpm start

## saltstack
echo "saltstack start"
wget http://219.146.255.198:8098/share/software/salt-repo-latest-2.el7.noarch.rpm
rpm -ivh salt-repo-latest-2.el7.noarch.rpm
sed -i 's/https:\/\/repo.saltstack.com/http:\/\/mirrors.ustc.edu.cn\/salt/g' /etc/yum.repos.d/salt-latest.repo
yum clean expire-cache
yum install -y salt-minion
sleep 2

sed -i '/#master:/cmaster: 10.8.0.170' /etc/salt/minion
sed -i '/default_include/s/^#//g' /etc/salt/minion
sed -i "/^#id/c id: $vpnIP" /etc/salt/minion

# mysql支持
yum install -y MySQL-python
wget http://219.146.255.198:8098/salt/1mysql/mysql_centos7.conf -O /etc/salt/minion.d/mysq.conf
systemctl restart salt-minion
sleep 1
systemctl enable salt-minion

## zabbix-agent
wget http://219.146.255.198:8098/share/software/zabbix-release-3.4-2.el7.noarch.rpm
rpm -ivh zabbix-release-3.4-2.el7.noarch.rpm
yum install -y zabbix-agent
sed -i '/^Server=/c Server=10.8.0.170' /etc/zabbix/zabbix_agentd.conf
systemctl start zabbix-agent.service
sleep 1
systemctl enable zabbix-agent.service

## 小帅环境
# cron
wget http://219.146.255.198:8098/salt/4cron/cron.centos7 -O /var/spool/cron/root

# platform-tools
cd /tmp/install/
wget http://219.146.255.198:8098/share/software/platform-tools.tar.gz
tar -xzvf platform-tools.tar.gz -C /usr/local/travelink/
ln -s /usr/local/travelink/platform-tools/adb /usr/local/bin/adb
yum install libgcc_s.so.1 -y
yum install ld-linux.so.2 -y
sleep 2

# mytools
echo 
echo "start mytools"
sleep 1
wget http://219.146.255.198:8098/salt/pkgs/mytools.tar.gz
tar -xzvf mytools.tar.gz -C /usr/local/travelink/
ln -s /usr/local/travelink/mytools/getactivity.sh /usr/local/bin/getactivity
ln -s /usr/local/travelink/mytools/getmanifest.sh /usr/local/bin/getmanifest
ln -s /usr/local/travelink/mytools/getpackagename.sh /usr/local/bin/getpackagename
ln -s /usr/local/travelink/mytools/getscreenshot.sh /usr/local/bin/getscreenshot
ln -s /usr/local/travelink/mytools/getmainactivity.sh /usr/local/bin/getmainactivity
ln -s /usr/local/travelink/mytools/difftxt.sh /usr/local/bin/difftxt
printf "%-60s%s\n" "mytools" "[OK]"
sleep 2

# downloadmovie
echo "start downloadmovie"
wget http://219.146.255.198:8098/salt/pkgs/m1905downloadmovie.tar.gz
tar -xzvf m1905downloadmovie.tar.gz -C /var/www/
printf "%-60s%s\n" "downloadmovie" "[OK]"
sleep 2

# mysh
echo
rsync -avL xiaoshuai@10.8.0.170::sh/ /var/www/sh/ --password-file=/etc/rsync.password
printf "%-60s%s\n" "mysh" "[OK]"
sleep 2

# 后台
tar -xzvf $key.tar.gz
mv -v ./travelinkBag/$htName /var/www/tlkcs
mv -v ./travelinkBag/mysql /var/www/
wget http://219.146.255.198:8098/conf/1config_xs -O /var/www/tlkcs/config.php
wget http://219.146.255.198:8098/conf/2config_xs -O /var/www/tlkcs/admin/config.php
wget http://219.146.255.198:8098/conf/update -O /var/www/tlkcs/admin/include/ext/update.php
wget http://219.146.255.198:8098/conf/config.inc -O /var/www/mysql/config.inc.php

echo "starttime:`date "+%Y-%m-%d %H:%M:%S"`" > /var/www/hotelinfo.txt
mysql -uroot -ptravelink -e "create database tlkcs"
mysql -uroot -ptravelink tlkcs < ./travelinkBag/$htName.sql
mysql -uroot -ptravelink <<EOF
use tlkcs;
update d_config set config="http://120.26.71.181/manage" where id=14;
update d_config set config="$vpnIP" where id=15;
update d_config set config="tlkcs" where id=16;
EOF

[ $houtaiCode == "v2" ]&&mv -v ./travelinkBag/share/ /var/www/||mkdir /var/www/share
mkdir /video/latestmovie
ln -s /video/latestmovie /var/www/share/latestmovie
chmod 777 -R /var/www/share/
printf "%-60s%s\n" "后台" "[OK]"
pkill nginx
sleep 1
nginx

# clean up db
wget http://219.146.255.198:8098/sh/20initializeDb.sh
sh /tmp/install/20initializeDb.sh tlkcs

# sync data from cloud
/usr/bin/php /var/www/tlkcs/statistics.php

## 云端占位
curl -s "http://120.26.71.181/manage/port/addNewHotel?vpn=$vpnIP&key=$key&version=$houtaiCode"

if [ $houtaiCode == v3 ];then
        # broadcast 3.0 only
        cd /tmp/install/
        wget http://219.146.255.198:8098/sh/serverConfig.tar.gz
        tar -xzvf serverConfig.tar.gz -C /var/www/
        /usr/bin/curl http://127.0.0.1/serverConfig/startBroad.php
        echo "/usr/bin/curl http://127.0.0.1/serverConfig/startBroad.php" >> /etc/rc.local
fi
rm -rf *
echo
echo "At least make a version !"
echo "Records hotelname and number of devices on the xiaoshuai cloud !"
echo
