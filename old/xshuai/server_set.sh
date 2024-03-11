#!/bin/bash 

dbUser=`cat /var/www/tlkcs/config.php |awk -F "'" '/DB_USER/{print$4}'`
dbPasswd=`cat /var/www/tlkcs/config.php |awk -F "'" '/DB_PWD/{print$4}'`

mysql -u$dbUser -p$dbPasswd -e "grant all privileges on *.* to 'xiaoshuai'@'%' identified by 'xshuai2015' with grant option;flush privileges;"

iptables -I INPUT 5 -s 10.8.0.0/26 -p tcp -m tcp --dport 3306 -j ACCEPT
service iptables save
