#!/bin/bash
# 功能：centOS部署PHP
# 格式：脚本名


#下载所需要的资源
echo 
echo "start 开始下载资源"
sleep 1
[ ! -d /root/temp/res ]&&mkdir -p /root/temp/res/
cd /root/temp/res
wget http://219.146.255.198:8098/share/software/php-5.3.27.tar.gz
chmod 777 *

#常用软件安装，部署
# php5.3
echo 
echo "start php"
sleep 1
cd /root/temp/res/
tar -xzvf php-5.3.27.tar.gz
cd /root/temp/res/php-5.3.27/
yum install -y epel-release
yum -y install libxml2-devel gcc gcc-c++ curl curl-devel libjpeg-devel libpng libpng-devel freetype-devel libmcrypt-devel openssl-devel openssl
./configure \
--prefix=/usr/local/xshuai/php \
--with-config-file-path=/usr/local/xshuai/php/etc \
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

cp -rfv /root/temp/res/php-5.3.27/php.ini-production /usr/local/xshuai/php/etc/php.ini
sed -i /^short_open_tag/s/Off/On/g /usr/local/xshuai/php/etc/php.ini
cp -rfv /usr/local/xshuai/php/etc/php-fpm.conf.default /usr/local/xshuai/php/etc/php-fpm.conf
sed -i /php-fpm.pid/s/\;//g /usr/local/xshuai/php/etc/php-fpm.conf
sed -i '/^user/c user = www' /usr/local/xshuai/php/etc/php-fpm.conf
sed -i '/^group/c group = www' /usr/local/xshuai/php/etc/php-fpm.conf
cp -rfv /root/temp/res/php-5.3.27/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm
echo /usr/local/xshuai/php/sbin/php-fpm >> /etc/rc.local
printf "%-60s%s\n" "PHP" "[OK]"
sleep 2
