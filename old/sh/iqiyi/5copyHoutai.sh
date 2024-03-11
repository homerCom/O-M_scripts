#!/bin/bash
# 功能：复制一个后台
# 格式：脚本名 旧后台名 新后台名

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 2 ]&&echo "参数数量错误"&&exit 1
[ ! -d /var/www/$1 ]&&echo "旧后台不存在"&&exit 1
[ -d /var/www/$2 ]&&echo "新后台已存在"&&exit 1

oldHtName=$1
dbUser="xiaoshuai"
dbPwd="travelink"
newHtName=$2

xsVpn=`ifconfig | awk '/10\.8\./{print $2}'|awk -F ':' '{print $2}'`

############### 数据库部分 ###############
echo "正在导出旧数据库。。。"
mysqldump -u$dbUser -p$dbPwd $oldHtName>./${oldHtName}.sql
echo "正在导入新数据库。。。"
mysql -u$dbUser -p$dbPwd -e "create database $newHtName;"
mysql -u$dbUser -p$dbPwd $newHtName < ${oldHtName}.sql
rm -v ./${oldHtName}.sql

mysql -u$dbUser -p$dbPwd << EOF
use $newHtName;
update d_config set config="http://120.26.71.181/manage" where id=14;
update d_config set config="$xsVpn:8000" where id=15;
update d_config set config="$newHtName" where id=16;
update h_canshu set x='192.168.123.250' where name='电影IP地址';
EOF

############## 后台部分 #############
echo "正在复制后台。。。"
rsync -av --exclude="ubc/*" --exclude="log/*" /var/www/$oldHtName/ /var/www/$newHtName/
chmod 777 -R /var/www/$newHtName

sed -i "s/\['DB_NAME'\]='.*'/\['DB_NAME'\]='$newHtName'/g" /var/www/$newHtName/config.php
sed -i "s/\['DB_NAME'\]='.*'/\['DB_NAME'\]='$newHtName'/g" /var/www/$newHtName/admin/config.php
sed -i "s/mysql_select_db('.*'/mysql_select_db('$newHtName'/g" /var/www/$newHtName/admin/include/ext/update.php

# nginx配置
cp -f /var/www/conf/tlkcs.conf /var/www/conf/${newHtName}.conf
sed -i s/tlkcs/$newHtName/g /var/www/conf/${newHtName}.conf
sed -i 8a"\\\tinclude /var/www/conf/${newHtName}.conf;" /var/www/conf/travelink.conf
service nginx restart

# 云端占位
hotelName=`mysql localplay -e  "select name from local_bar" | sed 1d`
randomip=$(($RANDOM%256)).$(($RANDOM%256)).$(($RANDOM%256)).$(($RANDOM%256))
curl -s "http://120.26.71.181/manage/port/addNewHotel?vpn=$randomip:8000&hotelname=$hotelName&version=3&project=$newHtName"

# 新后台清空数据库
bash /var/www/sh/iqiyi/20initializeDb.sh $newHtName

dateNow=`date "+%Y-%m-%d %H:%M:%S"`
echo -n "[$dateNow] [From:$oldHtName] [To:$NewHtName]" >> /var/www/houtai.txt
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
                echo -n "[hotelName:"$hotelName"]" >> /var/www/houtai.txt
                echo -n "[note:"$notes"]" >> /var/www/houtai.txt
                echo -n "[author:"$author"]" >> /var/www/houtai.txt
                echo >> /var/www/houtai.txt
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
echo
echo "
1，云端更改IP
2，增加crontab"
echo
