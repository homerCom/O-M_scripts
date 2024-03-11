#!/bin/bash
#功能：统计在线观看小帅影院人数

echo `date +"%Y-%m-%d %H:%M:%S"` >> /var/www/sh/connect.log
echo "观影在线人数：" >> /var/www/sh/connect.log
netstat -nap|grep -w '8080'|wc -l >> /var/www/sh/connect.log
echo "80口连接人数：" >> /var/www/sh/connect.log
netstat -nap|grep -w '80'|wc -l >> /var/www/sh/connect.log
echo "8000口在线人数：" >> /var/www/sh/connect.log
netstat -nap|grep -w '8000'|wc -l >> /var/www/sh/connect.log
echo -e '\n' >> /var/www/sh/connect.log
