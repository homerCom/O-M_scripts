#!/bin/bash
# 功能：删除后台及相应的数据库
# 格式：脚本名 后台名
[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 1 ]&&echo "参数不正确"&&exit 1
[ ! -d /var/www/$1 ]&&echo "相应后台不存在"&&exit 1

htName=$1
dbName=`awk -F "'" '/DB_NAME/{print $4}' /var/www/$htName/config.php`
dbPassword=`awk -F "'" '/DB_PWD/{print $4}' /var/www/$htName/config.php`

# nginx
if [ -f /var/www/conf/travelink.conf ];then
        rm -rfv /var/www/conf/${htName}.conf
        sed -i "/include.*${htName}.conf;/d" /var/www/conf/travelink.conf
        killall nginx
        sleep 1
        /usr/local/m1905/nginx/sbin/nginx
        sleep
        /usr/local/m1905/nginx_video/sbin/nginx
fi

echo "正在删除后台"
rm -vr /var/www/$htName
echo
echo "drop database"
mysql -uroot -p$dbPassword -e "drop database $dbName;"
echo "drop database success"
dateNow=`date "+%Y-%m-%d %H:%M:%S"`
echo -e "$htName has been deleted" >> /var/www/houtai.txt
echo -e "Time:\t$dateNow" >> /var/www/houtai.txt
echo >> /var/www/houtai.txt
echo
