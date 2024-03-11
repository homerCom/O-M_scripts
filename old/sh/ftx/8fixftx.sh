#!/bin/bash
sed -i 's/user  www/user  root/' /usr/local/m1905/nginx/conf/nginx.conf
sed -i 's/\[www\]/\[root\]/' /usr/local/m1905/php/etc/php-fpm.conf
sed -i 's/user = www/user = root/' /usr/local/m1905/php/etc/php-fpm.conf
sed -i 's/group = www/group = root/' /usr/local/m1905/php/etc/php-fpm.conf
sed -i 's/listen.owner = www/listen.owner = root/' /usr/local/m1905/php/etc/php-fpm.conf
sed -i 's/listen.group = www/listen.group = root/' /usr/local/m1905/php/etc/php-fpm.conf
sed -i 's/\/usr\/local\/m1905\/php\/sbin\/php-fpm.*/\/usr\/local\/m1905\/php\/sbin\/php-fpm \-R/g' /etc/rc.local

pkill nginx
pkill php
/usr/local/m1905/nginx/sbin/nginx
/usr/local/m1905/nginx_video/sbin/nginx
/usr/local/m1905/php/sbin/php-fpm -R
/usr/local/travelink/php/sbin/php-fpm

sed -i  '/mfs_status_check/s/^/#/' /var/spool/cron/root
pkill aria
sleep 5s
>/tmp/aria2c.session
/usr/bin/aria2c --conf-path=/etc/aria2c.conf -D
sed -i  '/mfs_status_check/s/^#//' /var/spool/cron/root
echo "done"
