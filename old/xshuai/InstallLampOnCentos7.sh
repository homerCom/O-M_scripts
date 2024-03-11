#!/bin/bash
# 功能：centOS部署小帅LNMP
# 格式：脚本名


#条件检查
[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ ! -d /root/temp/res ]&&mkdir -p /root/temp/res/

read -p 'please input you key:' vpncode

# 检查网络
echo "Checking the network..."
ping www.163.com -c 2 2>/dev/null
[ $? -ne 0 ]&&echo "Can't Ping To www.163.com,Check The Network Configuration Please"&&exit 1
printf "%-60s%s\n" "Network" "[OK]"


#下载所需要的资源
echo 
echo "start 开始下载资源"
sleep 1
cd /root/temp/res
wget http://120.26.231.165:8080/securehotel/client_xs$vpncode.tar.gz
wget http://219.146.255.198:8098/share/software/php-5.3.27.tar.gz
wget http://219.146.255.198:8098/share/conf/xshuai.conf
wget http://219.146.255.198:8098/share/conf/fastcgi.conf
chmod 777 *

#禁用防火墙及Selinux
systemctl stop firewalld.service
systemctl disable firewalld.service
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#更新yum源并安装必要软件
yum update -y
yum install -y epel-release
yum install -y net-tools vim wget lrzsz openvpn psmisc

#安装openvpn
tar -zxvf client_xs$vpncode.tar.gz -C /etc/openvpn/
openvpn --daemon --cd /etc/openvpn --config client_xsnew.conf
echo "openvpn --daemon --cd /etc/openvpn --config client_xsnew.conf" >> /etc/rc.local
sleep 3

#安装nginx
rpm -ivh  http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
yum install -y nginx
mkdir /var/www
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
mv xshuai.conf /etc/nginx/conf.d
mv fastcgi.conf /etc/nginx
systemctl start nginx.service
systemctl enable nginx.service

#安装php5.3
#新建用户和组
groupadd www
useradd -g www www

#安装必要组件
#yum update -y
yum -y install epel-release libxml2-devel gcc gcc-c++ curl curl-devel libjpeg-devel libpng libpng-devel freetype-devel libmcrypt-devel openssl openssl-devel

#常用软件安装，部署
# php5.3
echo 
echo "start php"
sleep 1
cd /root/temp/res/
tar -xzvf php-5.3.27.tar.gz
cd /root/temp/res/php-5.3.27/
yum -y install epel-release libxml2-devel gcc gcc-c++ curl curl-devel libjpeg-devel libpng libpng-devel freetype-devel libmcrypt-devel
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
chmod +x /etc/rc.local
printf "%-60s%s\n" "PHP" "[OK]"
sleep 2

#安装mariadb
yum install -y mariadb mariadb-server mariadb-devel
systemctl restart mariadb.service
systemctl enable mariadb.service
mysqladmin -u root password "123456"
yum install -y php php-mysql php-gd libjpeg* php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-bcmath php-mhash

#设置php5.3支持mariadb
sed -i 's/mysql.default_socket =/mysql.default_socket = \/var\/lib\/mysql\/mysql.sock/g' /usr/local/xshuai/php/etc/php.ini

#重新启动nginx、php、mariadb
systemctl restart nginx.service
systemctl restart mariadb.service
/etc/init.d/php-fpm restart

printf "%-60s%s\n" "LNMP" "[OK]"

#删除安装包
rm -rf client_xs$vpncode.tar.gz php-5.3.27.tar.gz

#显示网络信息
/usr/sbin/ifconfig