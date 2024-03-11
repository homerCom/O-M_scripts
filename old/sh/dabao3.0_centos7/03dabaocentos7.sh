#!/bin/bash
# 格式：脚本名 后台名 vpnCode
# 功能：打包小帅新后台（小帅3.0），并且生成vpn包，生成key
# 平台：centos7

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 2 ]&&echo "脚本名 后台名 vpnCode"&&exit 1
[ ! -d /var/www/$1 ]&&echo "相应后台不存在"&&exit 1
htname=$1
vpnCode=$2

[ `curl -sI http://update.xshuai.com:8098/vpns/client_xs$vpnCode.tar.gz | sed -n 1p | awk '{print $2}'` -ne 200 ]&&echo "vpnBag not exists"&&exit 1

dbname=`awk -F "'" '/DB_NAME/{print $4}' /var/www/$htname/config.php`
dbpwd=`awk -F "'" '/DB_PWD/{print $4}' /var/www/$htname/config.php`

# sql
echo "mysqldump.."
mysqldump -uroot -p$dbpwd $dbname>$htname.sql

# code and mysql
echo "开始复制相关目录。。。"
rsync -av --exclude="log/*" --exclude="ubc/*" --exclude=".svn" --exclude="admin/images/apk/*" --exclude="admin/images/music/*" --exclude="admin/updatedata/*" /var/www/$htname/ ./$htname/
mysql -uroot -p$dbpwd -e 'select apk_name from '$dbname'.h_apk;' | sed 1d | xargs -I {} cp -rfv /var/www/$htname/admin/{} ./$htname/admin/images/apk/
mysql -uroot -p$dbpwd -e 'select music_addr from '$dbname'.h_music;' | sed 1d | xargs -I {} cp -rfv /var/www/$htname/admin/{} ./$htname/admin/images/music/
cp -rfv /var/www/mysql .

mkdir -v travelinkBag
mv -v $htname $htname.sql mysql travelinkBag

echo "开始打包。。。"
timeNow=`date +%Y%m%d`
myIp=`ifconfig | awk '/:10\.8/{print $2}' | awk -F ':' '{print $2}'`
tar -czvf $htname-$myIp-$timeNow.tar.gz travelinkBag
key=`md5sum $htname-$myIp-$timeNow.tar.gz | cut -c 1-6`

echo "$htname-$myIp-$timeNow-v3.tar.gz" > $key.txt
cp $htname-$myIp-$timeNow.tar.gz $key.tar.gz
cp -rfv *.tar.gz $key.txt /mnt/release/
rm -rfv *.tar.gz $key.txt

# make vpn
cp -rfv /mnt/vpns/client_xs$vpnCode.tar.gz /mnt/vpns/vpn_$key.tar.gz

rm -r travelinkBag
echo
echo "打包完成，相关文件位置："
echo "本酒店的key为：$key"
echo "NEXT"
echo "在本机上运行这个脚本 wget http://update.xshuai.com:8098/sh/46startnet.sh"
echo
