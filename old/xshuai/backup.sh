#!/bin/bash
# 格式：脚本名 后台名
# 功能：打包小帅新后台（欢鹏）
# 平台：ubuntu 12.04，centOS_1905

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
#[ $# -ne 1 ]&&echo "参数不正确"&&exit 1
[ ! -d /var/www/tlkcs ]&&echo "相应后台不存在"&&exit 1

#创建备份目录
[ ! -d /var/www/backup ]&&mkdir -p /var/www/backup
cd /var/www/backup

htname="tlkcs"
dbname=`awk -F "'" '/DB_NAME/{print $4}' /var/www/$htname/config.php`
dbpwd=`awk -F "'" '/DB_PWD/{print $4}' /var/www/$htname/config.php`

# sql
echo "mysqldump.."
mysqldump -uroot -p$dbpwd $dbname>$htname.sql

# code and mysql
echo "开始复制相关目录。。。"
rsync -av --exclude="log/*" --exclude="ubc/*" --exclude=".svn" --exclude="admin/images/apk/*" --exclude="admin/images/music/*" /var/www/$htname/ ./$htname/
mysql -uroot -p$dbpwd -e 'select apk_name from '$dbname'.h_apk;' | sed 1d | xargs -I {} cp -rfv /var/www/$htname/admin/{} ./$htname/admin/images/apk/
mysql -uroot -p$dbpwd -e 'select music_addr from '$dbname'.h_music;' | sed 1d | xargs -I {} cp -rfv /var/www/$htname/admin/{} ./$htname/admin/images/music/
cp -rfv /var/www/mysql .

mkdir -v travelinkBag
mv -v $htname $htname.sql mysql travelinkBag

echo "开始打包。。。"
timeNow=`date +%Y%m%d`
myIp=`/sbin/ifconfig | awk '/:10.8/{print $2}' | awk -F ':' '{print $2}'`
tar -czvf $htname-$myIp-$timeNow-v3.tar.gz travelinkBag
rm -r travelinkBag
echo
echo "打包完成，目标文件已在当前目录下生成"

#删除6个月前的备份文件
find /var/www/backup -mtime +188 -exec rm -rf {} \;

#ftp上传
ftp -n<<!
open 219.146.255.198
user travelink haier123
binary
lcd /var/www/backup
prompt
put $htname-$myIp-$timeNow-v3.tar.gz
close
bye
!

echo
echo K.O.
echo
