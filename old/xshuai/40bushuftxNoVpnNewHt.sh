#!/bin/bash
# 功能：centos0921系统部署小帅新后台（欢鹏）
# 	条件：脚本和后台资源包在一个目录下，已经安装好vpn了
# 格式：脚本名

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $PWD != /root/temp/res ]&&echo "请将脚本置于/root/temp/res/目录下"&&exit 1
ls /root/temp/res | grep -Eq 'cs.*gz'
[ $? -ne 0 ]&&echo "当前目录下没有后台资源包"&&exit 1
htName=`ls /root/temp/res/ | awk -F '-' '/cs.*gz/{print $1}'`
hotelBag=`ls /root/temp/res/ | awk '/cs.*gz/{print $0}'`

echo "Checking the network..."
ping www.163.com -c 2 2>/dev/null
[ $? -ne 0 ]&&echo "Can't Ping To www.163.com,Check The Network Configuration Please"&&exit 1
printf "%-60s%s\n" "Network" "[OK]"

#下载所需要的资源
echo 
echo "start 开始下载资源"
sleep 1
[ ! -d /root/temp/res ]&&mkdir -p /root/temp/res/
cd /root/temp/res
wget http://219.146.255.198:8098/salt/cron/cron.xsnew
wget http://219.146.255.198:8098/share/software/php-5.3.27.tar.gz
wget http://219.146.255.198:8098/share/conf/travelink.conf
wget http://219.146.255.198:8098/share/software/ntfs-3g_ntfsprogs-2016.2.22.tgz
wget http://219.146.255.198:8098/share/software/platform-tools.tar.gz
wget http://219.146.255.198:8098/salt/pkgs/mytools.tar.gz
wget http://219.146.255.198:8098/salt/pkgs/m1905downloadmovie.tar.gz
wget http://219.146.255.198:8098/salt/1mysql/mysql.conf
wget http://219.146.255.198:8098/salt/pkgs/sh.tar.gz
wget http://219.146.255.198:8098/sh/20initializeDb.sh
chmod 777 *
printf "%-60s%s\n" "资源" "[OK]"

#crontab
cat cron.xsnew >> /var/spool/cron/root

#常用软件安装，部署
# php5.3
echo 
echo "start php"
sleep 1
cd /root/temp/res/
tar -xzvf php-5.3.27.tar.gz
cd /root/temp/res/php-5.3.27/
yum -y install libxml2-devel
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

make&&make install

cp -rfv /root/temp/res/php-5.3.27/php.ini-production /usr/local/travelink/php/etc/php.ini
sed -i /^short_open_tag/s/Off/On/g /usr/local/travelink/php/etc/php.ini
sed -i /'post_max_size = 8M'/c'post_max_size = 200M' /usr/local/travelink/php/etc/php.ini
sed -i /'upload_max_filesize = 2M'/c'upload_max_filesize = 200M' /usr/local/travelink/php/etc/php.ini
cp -rfv /usr/local/travelink/php/etc/php-fpm.conf.default /usr/local/travelink/php/etc/php-fpm.conf
sed -i /php-fpm.pid/s/\;//g /usr/local/travelink/php/etc/php-fpm.conf
sed -i '/^user/c user = www' /usr/local/travelink/php/etc/php-fpm.conf
sed -i '/^group/c group = www' /usr/local/travelink/php/etc/php-fpm.conf
cp -rfv /root/temp/res/php-5.3.27/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm
echo /usr/local/travelink/php/sbin/php-fpm >> /etc/rc.local
printf "%-60s%s\n" "PHP" "[OK]"
sleep 2

# nginx配置
echo 
echo "start nginx"
sleep 1
sed -i '$i include /var/www/conf/travelink.conf;' /usr/local/m1905/nginx/conf/nginx.conf
[ ! -d /var/www/conf ]&&mkdir -p /var/www/conf/
cp -rfv /root/temp/res/travelink.conf /var/www/conf/
printf "%-60s%s\n" "NGINX" "[OK]"
sleep 2

# vpn
xsVpn=`ifconfig | awk '/10.5./{print $2}'|awk -F ':' '{print $2}'`

# salt
echo 
echo "start salt"
sleep 1
sed -i '11c master: 10.5.0.17' /etc/salt/minion
sed -i '/default_include/s/^#//g' /etc/salt/minion
cp -v  /root/temp/res/mysql.conf /etc/salt/minion.d/
mv /etc/salt/pki/minion/minion_master.pub /etc/salt/pki/minion/minion_master.pub.1
service salt-minion restart
printf "%-60s%s\n" "salt" "[OK]"
sleep 2

# zabbix
echo 
echo "start zabbix"
sleep 1
sed -i '/Server=10.7.254.254/c Server=10.7.254.254,10.5.0.17' /etc/zabbix_agentd.conf
service zabbix-agent restart
printf "%-60s%s\n" "zabbix" "[OK]"
sleep 2

# other software
yum install nano -y
yum install nmap -y
yum install lsof -y
yum install sysstat -y
yum install dos2unix -y
yum install MySQL-python -y

echo 
echo "start axel"
sleep 1
rpm -Uvh http://219.146.255.198:8098/share/software/axel-2.4-1.el6.rf.x86_64.rpm
printf "%-60s%s\n" "axel" "[OK]"
cd /root/temp/res/
echo "start ntfs-3g"
echo 
sleep 1
tar -xzvf ntfs-3g_ntfsprogs-2016.2.22.tgz
cd /root/temp/res/ntfs-3g_ntfsprogs-2016.2.22
./configure
make&&make install
printf "%-60s%s\n" "ntfs-3g_ntfsprogs" "[OK]"
sleep 2

echo 
echo "start platform-tools"
sleep 1
cd /root/temp/res/
tar -xzvf platform-tools.tar.gz
mv -v ./platform-tools /usr/local/travelink/
ln -s /usr/local/travelink/platform-tools/adb /usr/local/bin/adb
yum install libgcc_s.so.1 --setopt=protected_multilib=false -y
yum install ld-linux.so.2 -y
printf "%-60s%s\n" "adb" "[OK]"
sleep 2

echo 
echo "start mytools"
sleep 1
tar -xzvf mytools.tar.gz
mv -fv /root/temp/res/mytools /usr/local/travelink/
ln -s /usr/local/travelink/mytools/getactivity.sh /usr/local/bin/getactivity
ln -s /usr/local/travelink/mytools/getmanifest.sh /usr/local/bin/getmanifest
ln -s /usr/local/travelink/mytools/getpackagename.sh /usr/local/bin/getpackagename
ln -s /usr/local/travelink/mytools/getscreenshot.sh /usr/local/bin/getscreenshot
ln -s /usr/local/travelink/mytools/getmainactivity.sh /usr/local/bin/getmainactivity
ln -s /usr/local/travelink/mytools/difftxt.sh /usr/local/bin/difftxt
printf "%-60s%s\n" "mytools" "[OK]"
sleep 2

echo 
echo "start downloadmovie"
sleep 1
tar -xzvf m1905downloadmovie.tar.gz
mv -v downloadmovie /var/www/
printf "%-60s%s\n" "downloadmovie" "[OK]"
sleep 2

echo
echo "start mysh"
sleep 1
tar -xzvf sh.tar.gz
mv -v sh /var/www/
printf "%-60s%s\n" "mysh" "[OK]"
sleep 2

# 后台
echo 
echo "start 后台"
sleep 1
tar -xzvf $hotelBag
sed -i "s/localhost/127.0.0.1/g" ./travelinkBag/$htName/config.php
sed -i "s/localhost/127.0.0.1/g" ./travelinkBag/$htName/admin/config.php
sed -i "s/\['DB_NAME'\]='.*'/\['DB_NAME'\]='tlkcs'/g" ./travelinkBag/$htName/config.php
sed -i "s/\['DB_NAME'\]='.*'/\['DB_NAME'\]='tlkcs'/g" ./travelinkBag/$htName/admin/config.php
sed -i "/DB_PWD/c \$config['DB_PWD']='123456';//数据库密码" ./travelinkBag/$htName/config.php
sed -i "/DB_PWD/c \$config['DB_PWD']='123456';//数据库密码" ./travelinkBag/$htName/admin/config.php
sed -i "s/localhost/127.0.0.1/g" ./travelinkBag/mysql/config.inc.php
dos2unix ./travelinkBag/$htName/config.php ./travelinkBag/$htName/admin/config.php ./travelinkBag/$htName/admin/include/ext/update.php ./travelinkBag/mysql/config.inc.php

echo "starttime:`date "+%Y-%m-%d %H:%M:%S"`" > /var/www/hotelinfo.txt
echo "hotelname:
oscode:centos0921
station:">>/var/www/hotelinfo.txt
mv -v /root/temp/res/travelinkBag/mysql /var/www/
ln -s /dev/shm/mysql.sock /var/lib/mysql/mysql.sock
mysql -uroot -p123456 -e "create database tlkcs"
mysql -uroot -p123456 tlkcs < ./travelinkBag/$htName.sql
mysql -uroot -p123456 <<EOF
use tlkcs;
update d_config set config="http://120.26.71.181/manage" where id=14;
update d_config set config="$xsVpn:8000" where id=15;
update d_config set config="tlkcs" where id=16;
EOF
mv -v ./travelinkBag/$htName ./travelinkBag/tlkcs
mv -v ./travelinkBag/tlkcs/ /var/www/
mkdir /var/www/share
mkdir /video/latestmovie
ln -s /video/latestmovie /var/www/share/latestmovie
chmod 777 -R /var/www/share/
printf "%-60s%s\n" "后台" "[OK]"
sleep 2
killall nginx
sleep 1
/usr/local/m1905/nginx/sbin/nginx
sleep 1
/usr/local/m1905/nginx_video/sbin/nginx
sleep 1
service php-fpm start

cd /root/temp/res/
sh /root/temp/res/20initializeDb.sh tlkcs
rm -rfv *
echo
echo K.O.
echo
