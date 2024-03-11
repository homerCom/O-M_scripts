#!/bin/bash
# 功能：从其他服务器上打包后台，部署到244上，云端有对应占位。
# 格式：脚本名 新后台名

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 1 ]&&echo "请输入新后台名称"&&exit 1
ls $PWD | grep -q tar.gz
[ $? -ne 0 ]&&echo "当前目录没有程序包"&&exit 1
tarBagName=`ls | grep tar.gz`
chmod 777 *
tar -xzvf $tarBagName

[ ! -d ./travelinkBag ]&&echo "当前目录下没有travelinkBag目录"&&exit 1
ls ./travelinkBag | grep -q cs$
[ $? -ne 0 ]&&rm -rfv ./travelinkBag&&echo "后台名必须以cs结尾！"&&exit 1
houtaiCode=`echo $tarBagName | awk -F '[-.]' '{print $7}'`

# 数据库
oldHtName=`ls ./travelinkBag | grep cs$`
htName=$1	#新后台名
[ -d /var/www/$htName ]&&echo "后台已存在！"&&exit 1
dbUser="root"
dbPwd="travelink"

mysql -u$dbUser -p$dbPwd -e "use $htName;" > /dev/null 2>&1
[ $? -eq 0 ]&&echo "数据库已存在！"&&exit 1
echo "开始处理数据库"
mysql -u$dbUser -p$dbPwd -e "create database $htName;"
mysql -u$dbUser -p$dbPwd $htName < ./travelinkBag/$oldHtName.sql

mysql -u$dbUser -p$dbPwd << EOF
use $htName;
update d_config set config="10.8.0.178:8000" where id=15;
update d_config set config="$htName" where id=16;
EOF

sed -i "s/localhost/127.0.0.1/g;s/\['DB_NAME'\]='.*'/\['DB_NAME'\]='$htName'/g;s/\['DB_USER'\]='.*'/\['DB_USER'\]='$dbUser'/g;s/\['DB_PWD'\]='.*'/\['DB_PWD'\]='$dbPwd'/g;" ./travelinkBag/$oldHtName/config.php
sed -i "s/localhost/127.0.0.1/g;s/\['DB_NAME'\]='.*'/\['DB_NAME'\]='$htName'/g;s/\['DB_USER'\]='.*'/\['DB_USER'\]='$dbUser'/g;s/\['DB_PWD'\]='.*'/\['DB_PWD'\]='$dbPwd'/g;" ./travelinkBag/$oldHtName/admin/config.php
sed -i "s/localhost/127.0.0.1/g;s/mysql_select_db('.*'/mysql_select_db('$htName'/g;/mysql_connect/c \\\t\$link = mysql_connect('127.0.0.1', '$dbUser','$dbPwd');//连接数据库" ./travelinkBag/$oldHtName/admin/include/ext/update.php

sed -i "s/localhost/127.0.0.1/g" ./travelinkBag/mysql/config.inc.php
dos2unix ./travelinkBag/$oldHtName/config.php ./travelinkBag/$oldHtName/admin/config.php ./travelinkBag/$oldHtName/admin/include/ext/update.php ./travelinkBag/mysql/config.inc.php
chmod 777 -R ./travelinkBag/$oldHtName

# nginx
cp /etc/nginx/conf.d/tlkcs.xs.conf /etc/nginx/conf.d/${htName}.xs.conf
sed -i s/tlkcs/$htName/g /etc/nginx/conf.d/${htName}.xs.conf
service nginx reload

# 移动后台和share
mv -v ./travelinkBag/$oldHtName /var/www/$htName
[ $houtaiCode == "v2" ]&&rsync -av ./travelinkBag/share/ /var/www/share/

rm -rf travelinkBag $tarBagName

# cron
#echo "
#*/30    *       * * *           /usr/bin/php5 /var/www/$htName/statistics.php
#6       */6     * * *           /usr/bin/php5 /var/www/$htName/onlineweather.php">>/var/spool/cron/crontabs/root

# 清空后台
bash /var/www/solo/20initializeDb.sh $htName

# 云端占位
randomip=$(($RANDOM%256)).$(($RANDOM%256)).$(($RANDOM%256)).$(($RANDOM%256))
curl -s "http://120.26.71.181/manage/port/addNewHotel?vpn=$randomip&hotelname=244占位&version=3&project=$htName"

#设置天气
sed -i "/#酒店天气/a\6       */6    * * *    /usr/local/travelink/php/bin/php /var/www/$htName/onlineweather.php" /var/spool/cron/root

dateNow=`date "+%Y-%m-%d %H:%M:%S"`
echo -n "[$dateNow] [From:$tarBagName] [To:$htName]" >> /var/www/houtai.txt
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
echo "
0，云端修改相关内容，云端填写VPN地址为10.8.0.178
1，/usr/local/travelink/php/bin/php /var/www/$htName/statistics.php 同步数据
2, /usr/local/travelink/php/bin/php /var/www/$htName/onlineweather.php" 
