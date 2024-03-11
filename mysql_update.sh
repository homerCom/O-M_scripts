#下载mariadb10.5.17
cd /usr/local/src
wget https://archive.mariadb.org/mariadb-10.5.17/bintar-linux-systemd-x86_64/mariadb-10.5.17-linux-systemd-x86_64.tar.gz --no-check-certificate
tar -zxvf mariadb-10.5.17-linux-systemd-x86_64.tar.gz

#备份
cp -r /data /bak-data
today=`date +%Y%m%d`
mkdir -p /back/mysql/bak-$today
cd /back/mysql/bak-$today
mysqldump -ukiosoft -p123456 --all-databases > alldb.sql

#停机
systemctl stop mysqld
#mysql -ukiosoft -p123456 -e "shutdown"
mv /usr/local/mysql/ /usr/local/bak-mysql-10.3.16

#升级mysql程序
cd /usr/local/src
mv mariadb-10.5.17-linux-systemd-x86_64 /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql

#升级启动文件
mv /etc/init.d/mysqld /etc/init.d/bak-mysqld
wget -P /etc/init.d 47.107.31.18/files/mysqld
chmod 755 /etc/init.d/mysqld
chkconfig mysqld on

#启动数据库
systemctl daemon-reload
systemctl start mysqld

#执行升级命令
/usr/local/mysql/bin/mysql_upgrade -ukiosoft -p123456 -s

mysql -ukiosoft -p123456 -e "ALTER TABLE `mysql`.`innodb_index_stats` FORCE;"
mysql -ukiosoft -p123456 -e "ALTER TABLE `mysql`.`innodb_table_stats` FORCE;"
/usr/local/mysql/bin/mysql_upgrade -ukiosoft -p123456 -s --force
