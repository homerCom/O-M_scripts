#install cmake
if [ ! -d /usr/local/bin/cmake ];
then
	yum -y install libaio expect libaio-devel bison bison-devel zlib-devel openssl openssl-devel ncurses ncurses-devel libcurl-devel libarchive-devel boost boost-devel  gcc gcc-c++ make perl kernel-headers kernel-devel pcre-devel
	cd /usr/local/src
	tar -zxvf cmake-3.12.1.tar.gz
	cd /usr/local/src/cmake-3.12.1
	./bootstrap
	gmake
	make -j 2
	make install
else
	echo "cmake already exists and does not need to be installed！"
fi

#install mariadb
if [ ! -d /usr/local/mysql ];
then
	find -H /etc/ | grep my.c 
	rm -rf /etc/my.cnf /etc/my.cnf.d/
	rpm -qa|grep mariadb*
	rpm -e  mariadb-libs-* --nodeps

	groupadd -r mysql
	useradd -r -g mysql -s /sbin/nologin -d /usr/local/mysql  -M mysql
	mkdir -pv /data
	chown -R mysql:mysql /data
	cd /usr/local/src 
	tar  -zxvf  mariadb-10.3.16.tar.gz
	cd  /usr/local/src/mariadb-10.3.16
	
	cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
	-DDEFAULT_CHARSET=utf8 \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DMYSQL_DATADIR=/data \
	-DSYSCONFDIR=/etc \
	-DWITHOUT_TOKUDB=1 \
	-DWITH_INNOBASE_STORAGE_ENGINE=1 \
	-DWITH_ARCHIVE_STPRAGE_ENGINE=1 \
	-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
	-DWIYH_READLINE=1 \
	-DWIYH_SSL=system \
	-DVITH_ZLIB=system \
	-DWITH_LOBWRAP=0 \
	-DMYSQL_UNIX_ADDR=/tmp/mysql.sock
	make
	make install
	
	cp /usr/local/src/config/my.cnf /etc/
	/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/data
	cp /usr/local/src/init/mysqld /etc/init.d/
	chmod 755 /etc/init.d/mysqld
	chmod 644 /etc/my.cnf
	chkconfig mysqld on
	systemctl daemon-reload
	service mysql restart
	echo  -e "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
	source /etc/profile
else
	echo "mysql already exists and does not need to be installed！"
fi
