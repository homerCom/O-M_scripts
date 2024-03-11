#!/bin/bash
# 格式：脚本名 后台名
# 功能：打包后台(HTTP),包括share下除了电影之外的所有资源
# 平台：ubuntu 12.04，centOS_1905
# 执行环境：把此脚本放置到一个空目录下执行
# 脚本名：02httpdabao.sh

# 打包后的目录结构
# ├── travelinkBag
# │   ├── mysql
# │   ├── share
# │   ├── yanshics
# │   └── yanshics.sql
# └── $htname-$myIp-$timeNow.tar.gz

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 1 ]&&echo "参数不正确"&&exit 1
[ ! -d /var/www/$1 ]&&echo "相应后台不存在"&&exit 1
[ ! \( `ls $PWD | wc -l` -eq 1 -a -f $0 \) ]&&echo "当前目录环境不符合要求"&&exit 1

htname=$1
dbname=`awk -F "'" '/DB_NAME/{print $4}' /var/www/$htname/config.php`
dbpwd=`awk -F "'" '/DB_PWD/{print $4}' /var/www/$htname/config.php`
picsql=`mysql -uroot -p$dbpwd -e 'select picadd from '$dbname'.h_pic;'|sed '1d'`
apksql=`mysql -uroot -p$dbpwd -e 'select apk_name from '$dbname'.h_apk;'|sed '1d'`
tvlistsql=`mysql -uroot -p$dbpwd -e 'select tv_list from '$dbname'.h_tvlist;'|sed '1d'`
musicsql=`mysql -uroot -p$dbpwd -e 'select music_addr from '$dbname'.h_music;'|sed '1d'`

##记录问题报告
echo "开始检测后台环境。。。"
## 检测h_apk,h_music,h_pic,h_tvlist四个表
[ -f ./report.txt ]&&rm -v ./report.txt
echo "=========================================">>report.txt
echo "      *******   "$htname"    ********">>report.txt
echo "=========================================">>report.txt
for pic in $picsql
do
        [ -f /var/www/$htname/admin/$pic ]&&echo $pic"...................ok"||echo /var/www/$htname/admin/$pic ----- 不存在|tee -a report.txt
done
for apk in $apksql
do
        [ -f /var/www/share/hvupdate/$apk ]&&echo $apk"....................ok"||echo /var/www/share/hvupdate/$apk  ----不存在|tee -a report.txt
done
for tvlist in $tvlistsql
do
        [ -f /var/www/share/tv/$tvlist ]&&echo $tvlist"....................ok"||echo /var/www/share/$tvlist  -----  不存在|tee -a report.txt
done
for music in $musicsql
do
        [ -f /var/www/$music ]&&echo $music"....................ok"||echo /var/www/$music -----不存在|tee -a report.txt
done
count=$(cat report.txt|wc -l)
if [ $count -eq 3 ];then
	echo "检测1通过。。。继续。。"
	rm -v report.txt
else
	echo "配置有问题，问题报告report.txt已生成。"&&exit 1
fi

echo
######################    检查完成    #############################
# 创建目录travelinkBag，./share/hvupdate/，./share/sounds/，./share/xxvideo等

echo "正在创建相关目录。。。"
mkdir -v travelinkBag share ./share/hvupdate 
for music in $musicsql
do
	musicdir=${music%/*}
        [ ! -d ./$musicdir ]&&echo "正在创建$musicdir..."&&mkdir -v ./$musicdir
done
echo "mysqldump..."
mysqldump -uroot -p$dbpwd $dbname>$htname.sql

echo "开始复制相关目录。。。"
rsync -av --exclude="log/*" --exclude="ubc/*" /var/www/$htname/ ./$htname/
cp -vr /var/www/mysql .
cp -vr /var/www/share/tv/ ./share/
mysql -uroot -p$dbpwd -e 'select apk_name from '$dbname'.h_apk;' | sed 1d | xargs -I {} cp -v /var/www/share/hvupdate/{} ./share/hvupdate/
mysql -uroot -p$dbpwd -e 'select music_addr from '$dbname'.h_music;' | sed 1d | xargs -I {} cp -vr /var/www/{} ./{}

mv -v $htname $htname.sql mysql share travelinkBag
echo "开始打包。。。"
timeNow=`date +%Y%m%d`
myIp=`ifconfig | awk '/:10.5/{print $2}' | awk -F ':' '{print $2}'`
tar -czvf $htname-$myIp-$timeNow.tar.gz travelinkBag
rm -r travelinkBag
echo
echo "打包完成，目标文件已在当前目录下生成"
