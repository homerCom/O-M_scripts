#!/bin/bash
# 功能：复制一个后台
# 格式：脚本名 旧后台名 新后台名
# 备注：1，新后台的数据库名和后台名是一样的；
#	2，新后台的apk资源，下载资源和原来的后台用的是同一份
# 	3，此脚本会清空h_deletepic,h_rooms,h_guest三个表
#	4，尽量用此脚本生成新后台，因为会有相应记录，便于管理

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 2 ]&&echo "参数数量错误"&&exit 1
[ ! -d /var/www/$1 ]&&echo "旧后台不存在"&&exit 1
[ -d /var/www/$2 ]&&echo "新后台已存在"&&exit 1

oldHtName=$1
oldDbName=`awk -F "'" '/DB_NAME/{print $4}' /var/www/$oldHtName/config.php`
dbPassword=`awk -F "'" '/DB_PWD/{print $4}' /var/www/$oldHtName/config.php`
newHtName=$2

############### 数据库部分 ###############
echo "正在导出旧数据库。。。"
mysqldump -uroot -p$dbPassword $oldDbName>./$oldDbName.sql
echo "正在导入新数据库。。。"
mysql -uroot -p$dbPassword -e "create database $newHtName;"
mysql -uroot -p$dbPassword $newHtName < $oldDbName.sql

# 清空相关的表
mysql -uroot -p$dbPassword <<EOF
use $newHtName;
truncate table h_deletepic;
truncate table h_rooms;
truncate table h_guest;
EOF
echo "清空相关数据库结束"

############## 后台部分 #############
echo "正在复制后台。。。"
rsync -av --exclude="ubc/*" --exclude="log/*" /var/www/$oldHtName/ /var/www/$newHtName/
chmod 777 -R /var/www/$newHtName
#删除多余的文件
find /var/www/$newHtName | grep ".svn$" | xargs rm -rfv

sed -i "s/\['DB_NAME'\]='.*'/\['DB_NAME'\]='$newHtName'/g" /var/www/$newHtName/config.php
sed -i "s/\['DB_NAME'\]='.*'/\['DB_NAME'\]='$newHtName'/g" /var/www/$newHtName/admin/config.php
sed -i "s/mysql_select_db('.*'/mysql_select_db('$newHtName'/g" /var/www/$newHtName/admin/include/ext/update.php
rm -v ./$oldDbName.sql

# nginx配置
if [ -f /var/www/conf/travelink.conf ];then
        cp -f /var/www/conf/tlkcs.conf /var/www/conf/${newHtName}.conf
        sed -i s/tlkcs/$newHtName/g /var/www/conf/${newHtName}.conf
        sed -i 8a"\\\tinclude /var/www/conf/${newHtName}.conf;" /var/www/conf/travelink.conf
        killall nginx
        sleep 1
        /usr/local/m1905/nginx/sbin/nginx
        sleep 1
        /usr/local/m1905/nginx_video/sbin/nginx
fi

dateNow=`date "+%Y-%m-%d %H:%M:%S"`
echo -e "From:\t$oldHtName" | tee -a /var/www/$newHtName/updateHistory.txt /var/www/houtai.txt
echo -e "To:\t$newHtName" | tee -a /var/www/$newHtName/updateHistory.txt /var/www/houtai.txt
echo -e "Time:\t$dateNow" | tee -a /var/www/$newHtName/updateHistory.txt /var/www/houtai.txt
echo
while true
do
        read -e -p "新后台酒店名：" hotelName
        read -e -p "输入一些注释（一行）：" notes
        read -e -p "你是谁：" author
        echo
        echo "*********************************"
	echo "新后台酒店名："$hotelName
        echo "注释的内容："$notes
        echo "后台创建人："$author
        echo "*********************************"
        echo 
        while true; 
        do
            read -p "确定输入请按0，重新输入请按1：" yn
            case $yn in
                0)
                echo -e "hotelName:\t"$hotelName | tee -a /var/www/$newHtName/updateHistory.txt /var/www/houtai.txt
                echo -e "note:\t"$notes | tee -a /var/www/$newHtName/updateHistory.txt /var/www/houtai.txt
                echo -e "author:\t"$author | tee -a /var/www/$newHtName/updateHistory.txt /var/www/houtai.txt
		echo | tee -a /var/www/$newHtName/updateHistory.txt /var/www/houtai.txt
                break 2
                ;;
                1)
                continue 2
                ;;
                * )
                echo "您的输入有误，请重新输入"
                continue
                ;;
            esac
        done
done
echo
echo "done"
echo
