#!/bin/bash
# 格式：脚本名 后台名
# 功能：打包小帅新后台（小帅3.0）
# 平台：ubuntu 12.04，centOS_1905

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 1 ]&&echo "参数不正确"&&exit 1
[ ! -d /var/www/$1 ]&&echo "相应后台不存在"&&exit 1

htname=$1
[ `cat /var/www/$htname/VERSION` != 3.0 ]&&echo "houtai code error!"&&exit 1
dbuser=`awk -F "'" '/DB_USER/{print $4}' /var/www/$htname/config.php`
dbname=`awk -F "'" '/DB_NAME/{print $4}' /var/www/$htname/config.php`
dbpwd=`awk -F "'" '/DB_PWD/{print $4}' /var/www/$htname/config.php`

# sql
echo "mysqldump.."
mysqldump -u$dbuser -p$dbpwd $dbname>$htname.sql
version=`mysql -u$dbuser -p$dbpwd $dbname -e "select dataVersion from h_update_version where module='all' and dataVersion=(select max(dataVersion) from h_update_version);" | sed 1d`

# code and mysql
echo "开始复制相关目录。。。"
rsync -av --exclude="log/*" --exclude="ubc/*" --exclude=".svn" --exclude="admin/images/apk/*" --exclude="admin/images/music/*" --exclude="admin/updatedata/*" /var/www/$htname/ ./$htname/
mysql -u$dbuser -p$dbpwd -e 'select apk_name from '$dbname'.h_apk;' | sed 1d | xargs -I {} cp -rfv /var/www/$htname/admin/{} ./$htname/admin/images/apk/
mysql -u$dbuser -p$dbpwd -e 'select music_addr from '$dbname'.h_music;' | sed 1d | xargs -I {} cp -rfv /var/www/$htname/admin/{} ./$htname/admin/images/music/
cp -rfv /var/www/mysql .

mkdir -v travelinkBag
mv -v $htname $htname.sql mysql travelinkBag

echo "开始打包。。。"
timeNow=`date +%Y%m%d`
#myIp=`ifconfig | awk '/:10\.8/{print $2}' | awk -F ':' '{print $2}'`
myIp=`ip a | awk '/10\.8\./{print $2}'`
tarName=$htname-$myIp-$timeNow-3-v$version.tar.gz
tar -czvf $tarName travelinkBag
[ ! -d /var/www/tarbag/ ]&&mkdir /var/www/tarbag/
mv *.tar.gz /var/www/tarbag/
rm -r travelinkBag
echo
echo "打包完成，相关文件位置："
echo "/var/www/tarbag/$tarName"
echo "相关命令
wget http://219.146.255.198:someport/tarbag/$tarName
ncftpput -u xiaoshuai 219.146.255.198 /houtai /var/www/tarbag/$tarName
部署脚本 
wget http://219.146.255.198:8098/sh/40bushuftxNoVpnHt.sh"
