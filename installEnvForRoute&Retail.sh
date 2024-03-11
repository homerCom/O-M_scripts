#!/bin/bash
# author:lucaszhang@techtrex.com
# date:2022.3.11


[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ ! -f /usr/local/src/softwares.zip ]&&echo "Softwares tar is not in '/usr/local/src/',check please"&&exit 1

#install softwares
yum install -y vim wget lrzsz unzip

#unzip softwares
wget -P /usr/local/src http://download.vaststar.net/softwares.zip --no-check-certificate
unzip -d /usr/local/src/ /usr/local/src/softwares.zip

#timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

#update yum
systemctl stop firewalld
systemctl disable firewalld
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache
yum -y update

#install php
if [ ! -d /usr/local/php ];
then
	echo "start install php"
	groupadd www
	useradd -r -g www -s /sbin/nologin -d /usr/local/php/ -M www
	mkdir -pv /var/www
	chown  -R  www:www  /var/www
	yum install -y gcc gcc-c++ libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel curl curl-devel openssl openssl-devel libwebp libwebp-devel readline-devel
	cd /usr/local/src
	tar -zxvf libzip-1.2.0.tar.gz
	cd libzip-1.2.0
	./configure --prefix=/usr/local/libzip 
	make  -j  2 && make install
	cp /usr/local/libzip/lib/libzip/include/zipconf.h /usr/local/include/zipconf.h
	echo "/usr/local/libzip/lib64
	/usr/local/libzip/lib
	/usr/lib
	/usr/lib64" >> /etc/ld.so.conf.d/lib.conf 
	ldconfig -v
	
	cd /usr/local/src
	tar -xzvf php-7.3.7.tar.gz
	cd /usr/local/src/php-7.3.7
	
	./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysqli=mysqlnd --with-iconv-dir=/usr --with-gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr --with-webp-dir=/usr --with-zlib --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --enable-mbregex --enable-fpm --enable-mbstring --with-openssl --with-mhash --enable-pcntl --enable-sockets --enable-soap --without-pear --with-bz2 --enable-calendar --enable-ftp --enable-ctype --enable-exif --disable-ipv6  --enable-pdo --with-pdo-mysql=mysqlnd --enable-phar --with-curl --with-tsrm-pthreads  --enable-wddx --with-libzip=/usr/local/libzip --with-gettext --enable-zip --with-readline --enable-opcache
	
	make -j 2 
	make  install
	ln -sf /usr/local/php/bin/php /usr/bin/php
	cp /usr/local/src/init/php-fpm /etc/init.d/
	chmod 755 /etc/init.d/php-fpm
	chkconfig --level 234 php-fpm on
	echo -e 'export PATH=$PATH:/usr/local/php/bin' >> /etc/profile
	source /etc/profile
	cp /usr/local/src/config/php.ini /usr/local/php/etc/php.ini
	cp /usr/local/src/config/php-fpm.conf /usr/local/php/etc/php-fpm.conf
	cp /usr/local/src/config/www.conf /usr/local/php/etc/php-fpm.d/www.conf
	cp /usr/local/src/config/so/* /usr/local/php/lib/php/extensions/no-debug-non-zts-20180731/
	mkdir /usr/local/php/etc/ssl
	cp /usr/local/src/config/cert/curl-ca-bundle.crt /usr/local/php/etc/ssl/
	systemctl start php-fpm 
	echo "php installation complete."
else
	echo "php already exists and does not need to be installed！"
fi

##install nginx
if [ ! -d /usr/local/nginx ];
then
	yum -y install gcc gcc-c++ autoconf automake zlib zlib-devel openssl openssl-devel pcre*
	groupadd nginx 
	useradd -g nginx -M -s /sbin/nologin nginx
	tar -zxvf /usr/local/src/nginx-1.20.1.tar.gz -C /usr/local/src
	cd  /usr/local/src/nginx-1.20.1
	
	./configure --prefix=/usr/local/nginx \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_mp4_module \
	--with-http_random_index_module \
	--with-http_realip_module \
	--with-http_secure_link_module \
	--with-http_slice_module \
	--with-http_ssl_module \
	--with-http_stub_status_module \
	--with-http_sub_module \
	--with-http_v2_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-stream \
	--with-stream_realip_module \
	--with-stream_ssl_module \
	--with-stream_ssl_preread_module \
	--with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' \
	--with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie'
	
	make -j 2
	make install
	ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
	cp -r /usr/loca/src/script /
	mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.origin
	cp /usr/local/src/config/nginx/nginx.conf /usr/local/nginx/conf/
	mkdir -p /usr/local/nginx/conf/ssl
	mkdir -p /usr/local/nginx/conf/conf.d
	cp /usr/local/src/config/nginx/conf.d/* /usr/local/nginx/conf/conf.d/
	cp /usr/local/src/init/nginx /etc/init.d/
	chmod  755  /etc/init.d/nginx
	chkconfig  --add nginx 
	chkconfig   --level 234 nginx on
	/sbin/chkconfig nginx on
	systemctl start nginx
	echo "nginx installation complete."
else
	echo "nginx already exists and does not need to be installed！"
fi

#mysql client
if [ ! -f /usr/bin/mysql ];
then
    mkdir -p /usr/local/mysql/bin/	
    cp /usr/local/src/mysql /usr/local/mysql/bin/
    cp /usr/local/src/mysqldump /usr/local/mysql/bin/
    chmod +x /usr/local/mysql/bin/mysql
    chmod +x /usr/local/mysql/bin/mysqldump
    ln -s /usr/local/mysql/bin/mysql /usr/bin
    ln -s /usr/local/mysql/bin/mysqldump /usr/bin
fi

#install node
if [ ! -d /usr/local/node ];
then
	cd  /usr/local/src
	tar -zxvf node-v12.18.1-linux-x64.tar.gz
	mv  node-v12.18.1-linux-x64/  /usr/local/node
	ln -s /usr/local/node/bin/npm /usr/bin/npm
	ln -s /usr/local/node/bin/node /usr/bin/node
	/usr/local/bin/npm  install forever -g
	cp /usr/local/src/init/node /etc/init.d/
	chmod 755 /etc/init.d/node
	chkconfig  --add node
	chkconfig   --level 234  node  on
	npm install -g pm2
	ln -s /usr/local/node/bin/pm2 /usr/bin/
	echo "node installation complete."
else
	echo "node already exists and does not need to be installed！"
fi


#install redis
if [ ! -d /usr/local/redis ];
then
	yum -y install gcc gcc-c++ kernel-devel tcl make
	cd  /usr/local/src
	tar -xzf redis-5.0.4.tar.gz
	cd redis-5.0.4
	make PREFIX=/usr/local/redis install
	mkdir /usr/local/redis/etc/
	cp /usr/local/src/config/redis.conf /usr/local/redis/etc/
	cd /usr/local/redis/bin/
	cp redis-benchmark redis-cli redis-server /usr/bin/
	echo -e "export PATH=$PATH:/usr/local/redis/bin" >> /etc/profile
	source /etc/profile
	cp /usr/local/src/init/redis /etc/init.d/redis
	chmod 755 /etc/init.d/redis
	chkconfig --add  redis
	chkconfig --level 234  redis  on
	systemctl start redis

else
        echo "redis already exists and does not need to be installed！"
fi


#install docker
if [ ! -f /usr/bin/docker-compose ];
then
	cd  /usr/local/src
	yum install -y lib*  libsec* container-selinux*
	rpm -ivh containerd.io-1.2.6-3.3.el7.x86_64.rpm 
	rpm -ivh docker-ce-19.03.0-3.el7.x86_64.rpm docker-ce-cli-19.03.0-3.el7.x86_64.rpm
	\cp /usr/local/src/docker-compose /usr/local/bin/
	chmod +x /usr/local/bin/docker-compose
	ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
	systemctl start docker
	systemctl enable docker
else
	echo "docker already exists and does not need to be installed！"
fi

#create dir
if [ ! -d /KiosoftApplications ];
then
	mkdir -pv /KiosoftApplications/WebApps/kiosk_laundry_portal
	mkdir -pv /KiosoftApplications/WebApps/kiosk_value_code
	mkdir -pv /KiosoftApplications/WebApps/kiosk_web_rss
	mkdir -pv /KiosoftApplications/WebApps/kiosk_web_lcms
	mkdir -pv /KiosoftApplications/WebApps/oldversion
	mkdir -pv /KiosoftApplications/Licenses
	mkdir -pv /KiosoftApplications/ServerApps/TTI_ReportServer
	mkdir -pv /KiosoftApplications/ServerApps/TTI_Proxy
	mkdir -pv /KiosoftApplications/ServerApps/TTI_tcp
	mkdir -pv /KiosoftApplications/ServerApps/oldversion
else
	echo "documents exists"
fi

crontab
if [ ! -d /script ];
then
        mkdir -v /script
        mkdir -pv /back/mysql/dir
        mkdir -pv /usr/local/nginx/logs/oldversion/
        cp /usr/local/src/script/cut_nginx_log.sh /script/
        cp /usr/local/src/script/backupmysql.sh /script/
        chmod 755 /script/*
			echo "#backup mysql" >> /var/spool/cron/root
			echo "15  4  *  *  *  sh  /script/backupmysql.sh > /dev/null 2 >&1" >> /var/spool/cron/root
			echo "#nginx log cut" >> /var/spool/cron/root
			echo "0  0  *  *  *  sh /script/cut_nginx_log.sh > /dev/null 2 >&1" >> /var/spool/cron/root
else
        echo "documents /script exists"
fi
