#!/bin/bash
#用法：脚本 后台名
ip=192.168.1.222
htname=$1

[ $# -ne 1 ]&&echo "参数不正确"&&exit 1
[ -d /var/www/$1 ]&&echo "后台$htname已存在！"&&exit 1

echo "开始复制后台........"
/usr/bin/rsync -av root@$ip:/var/www/$htname /var/www
echo "后台复制完成！"
echo "开始拷贝数据库........."
mysql -uroot -phappyview -e "create database IF NOT EXISTS $1"
mysqldump -h$ip -uroot -p123456 $htname | mysql -h localhost -uroot -phappyview $htname
echo "数据库拷贝完成！"
sed -i 's/123456/happyview/g' /var/www/$htname/config.php
sed -i 's/123456/happyview/g' /var/www/$htname/admin/config.php
echo "Finish!"
