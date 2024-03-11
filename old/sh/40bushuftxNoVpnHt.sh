#!/bin/bash
# 功能：在风霆的centOS 6.6部署后台，2.0,3.0通用
# 	条件：脚本和后台资源包在一个目录下，已经安装好vpn了
# 格式：脚本名

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $PWD != /root/temp/res ]&&echo "请将脚本置于/root/temp/res/目录下"&&exit 1
ip a | grep -q "10\.8"
[ $? -ne 0 ]&&echo "请先安装小帅vpn"&&exit 1
ls /root/temp/res | grep -Eq 'cs.*gz'
[ $? -ne 0 ]&&echo "当前目录下没有后台资源包"&&exit 1
htName=`ls /root/temp/res/ | awk -F '-' '/cs.*gz/{print $1}'`
hotelBag=`ls /root/temp/res/ | awk '/cs.*gz/{print $0}'`
houtaiCode=`ls /root/temp/res/ | awk -F '[-.]' '{print $7}'`

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
wget http://219.146.255.198:8098/salt/4cron/cron.xs.centos
wget http://219.146.255.198:8098/share/software/php-5.3.27.tar.gz
wget http://219.146.255.198:8098/share/software/ntfs-3g_ntfsprogs-2016.2.22.tgz
wget http://219.146.255.198:8098/share/software/platform-tools.tar.gz
wget http://219.146.255.198:8098/salt/pkgs/mytools.tar.gz
wget http://219.146.255.198:8098/salt/pkgs/m1905downloadmovie.tar.gz
wget http://219.146.255.198:8098/sh/20initializeDb.sh
wget http://219.146.255.198:8098/sh/1updatesalt-minion.sh
chmod 777 *
printf "%-60s%s\n" "资源" "[OK]"

#crontab
sed -i '1i# Lines below here are managed by Salt, do not edit' /var/spool/cron/root
cat cron.xs.centos >> /var/spool/cron/root

# rsync
echo haier123 > /etc/rsync.password&&chmod 600 /etc/rsync.password

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

wget http://219.146.255.198:8098/conf/php.ini -O /usr/local/travelink/php/etc/php.ini
wget http://219.146.255.198:8098/conf/php-fpm.conf -O /usr/local/travelink/php/etc/php-fpm.conf
wget wget http://219.146.255.198:8098/conf/php-fpm -O /etc/init.d/php-fpm
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
wget http://219.146.255.198:8098/conf/travelink.conf -O /var/www/conf/travelink.conf
printf "%-60s%s\n" "NGINX" "[OK]"
sleep 2

# vpn
xsVpn=`ip a | awk '/10\.8\./{print $2}'`

# salt
echo 
echo "start salt"
sleep 1
sed -i '11c master: 10.8.0.170' /etc/salt/minion
sed -i '/default_include/s/^#//g' /etc/salt/minion
sed -i "/^id/c id: $xsVpn" /etc/salt/minion
wget http://219.146.255.198:8098/salt/1mysql/mysql.conf -O /etc/salt/minion.d/mysql.conf
chmod 644 /etc/salt/minion.d/mysql.conf
mv /etc/salt/pki/minion/minion_master.pub /etc/salt/pki/minion/minion_master.pub.1
service salt-minion restart
sleep 1
cd /root/temp/res/
sh 1updatesalt-minion.sh
printf "%-60s%s\n" "salt" "[OK]"
sleep 2

# zabbix
echo 
echo "start zabbix"
sleep 1
sed -i '/Server=10.7.254.254/c Server=10.7.254.254,10.8.0.170' /etc/zabbix_agentd.conf
service zabbix-agent restart
printf "%-60s%s\n" "zabbix" "[OK]"
sleep 2

# other software
yum -y install nano nmap tcpdump curl sysstat lsof dos2unix MySQL-python man ftp ntfs-3g iftop

echo 
echo "start axel"
sleep 1
rpm -Uvh http://219.146.255.198:8098/share/software/axel-2.4-1.el6.rf.x86_64.rpm
printf "%-60s%s\n" "axel" "[OK]"
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
tar -xzvf m1905downloadmovie.tar.gz -C /var/www/
printf "%-60s%s\n" "downloadmovie" "[OK]"
sleep 2

echo
rsync -avL xiaoshuai@10.8.0.170::sh/ /var/www/sh/ --password-file=/etc/rsync.password
printf "%-60s%s\n" "mysh" "[OK]"
sleep 2

# 后台
echo 
echo "start 后台"
sleep 1
echo "starttime:`date "+%Y-%m-%d %H:%M:%S"`" > /var/www/hotelinfo.txt
tar -xzvf $hotelBag
mv -v ./travelinkBag/$htName /var/www/tlkcs
mv -v /root/temp/res/travelinkBag/mysql /var/www/
wget http://219.146.255.198:8098/conf/1config -O /var/www/tlkcs/config.php
wget http://219.146.255.198:8098/conf/2config -O /var/www/tlkcs/admin/config.php
wget http://219.146.255.198:8098/conf/update -O /var/www/tlkcs/admin/include/ext/update.php
wget http://219.146.255.198:8098/conf/config.inc -O /var/www/mysql/config.inc.php

ln -s /dev/shm/mysql.sock /var/lib/mysql/mysql.sock
mysql -uroot -p123456 -e "create database tlkcs"
mysql -uroot -p123456 tlkcs < ./travelinkBag/$htName.sql
mysql -uroot -p123456 <<EOF
use tlkcs;
update d_config set config="http://120.26.71.181/manage" where id=14;
update d_config set config="$xsVpn:8000" where id=15;
update d_config set config="tlkcs" where id=16;
EOF

[ $houtaiCode == v2 ]&&mv -v ./travelinkBag/share/ /var/www/||mkdir /var/www/share
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

# 清空数据库
bash /root/temp/res/20initializeDb.sh tlkcs

# sync data
curl -s "http://120.26.71.181/manage/port/addNewHotel?version=$houtaiCode"
/usr/local/travelink/php/bin/php /var/www/tlkcs/statistics.php

if [ $houtaiCode == v3 ];then
	# broadcast 3.0 only
	cd /root/temp/res/
	wget http://219.146.255.198:8098/sh/serverConfig.tar.gz
	tar -xzvf serverConfig.tar.gz -C /var/www/
	/usr/bin/curl http://127.0.0.1:8000/serverConfig/startBroad.php
	echo "/usr/bin/curl http://127.0.0.1:8000/serverConfig/startBroad.php" >> /etc/rc.local
fi
echo
echo "At least make a version !"
echo "Records hotelname and number of devices on the xiaoshuai cloud !"
echo
rm -rf *
