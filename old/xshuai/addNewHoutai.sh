#!/bin/bash
# 功能：在服务器部署多个后台。
# 前提：服务器上至少已经存在一个后台
# 格式：脚本名 新后台名
# 备注: 数据库用户名：root  密码：123456

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 1 ]&&echo "请输入新后台名称,请检查"&&exit 1
[ -d /var/www/$1 ]&&echo "新后台已存在"&&exit 1
[ `ls $PWD | wc -l` -ne 2 ]&&echo "当前目录不符合环境要求"&&exit 1
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

# 备注: 数据库用户名：root  密码：123456
user="root"
dbPwd="123456"

echo "数据库密码："$dbPwd

yum install dos2unix -y

mysql -u$user -p$dbPwd -e "use $htName;" > /dev/null 2>&1
[ $? -eq 0 ]&&echo "数据库已存在！"&&exit 1
echo "开始处理数据库"
mysql -u$user -p$dbPwd -e "create database $htName;"
mysql -u$user -p$dbPwd $htName < ./travelinkBag/$oldHtName.sql

sed -i "s/localhost/127.0.0.1/g" ./travelinkBag/$oldHtName/config.php
sed -i "s/\['DB_NAME'\]='.*'/\['DB_NAME'\]='$htName'/g" ./travelinkBag/$oldHtName/config.php
sed -i "/DB_PWD/c \$config['DB_PWD']='$dbPwd';//数据库密码" ./travelinkBag/$oldHtName/config.php

sed -i "s/localhost/127.0.0.1/g" ./travelinkBag/$oldHtName/admin/config.php
sed -i "s/\['DB_NAME'\]='.*'/\['DB_NAME'\]='$htName'/g" ./travelinkBag/$oldHtName/admin/config.php
sed -i "/DB_PWD/c \$config['DB_PWD']='$dbPwd';//数据库密码" ./travelinkBag/$oldHtName/admin/config.php

sed -i "s/localhost/127.0.0.1/g" ./travelinkBag/$oldHtName/admin/include/ext/update.php
sed -i "s/mysql_select_db('.*'/mysql_select_db('$htName'/g" ./travelinkBag/$oldHtName/admin/include/ext/update.php
sed -i "/mysql_connect/c \\\t\$link = mysql_connect('127.0.0.1', 'root','$dbPwd');//连接数据库" ./travelinkBag/$oldHtName/admin/include/ext/update.php

sed -i "s/localhost/127.0.0.1/g" ./travelinkBag/mysql/config.inc.php
dos2unix ./travelinkBag/$oldHtName/config.php ./travelinkBag/$oldHtName/admin/config.php ./travelinkBag/$oldHtName/admin/include/ext/update.php ./travelinkBag/mysql/config.inc.php
chmod 777 -R ./travelinkBag/$oldHtName

# 开始移动后台
mv -v ./travelinkBag/$oldHtName /var/www/$htName
[ ! -d /var/www/mysql/ ]&&mv -v ./travelinkBag/mysql/ /var/www/&&chmod 755 -R /var/www/mysql
[ $houtaiCode == "v2" ]&&rsync -av ./travelinkBag/share/ /var/www/share/

rm -rf travelinkBag $tarBagName

# nginx配置
if [ -f /var/www/conf/travelink.conf ];then
	if [ ! -f /var/www/conf/tlkcs.conf ];then
		wget -P /var/www/conf/ http://219.146.255.198:8223/conf/tlkcs.conf
		chmod 777 /var/www/conf/tlkcs.conf
	fi
	cp -f /var/www/conf/tlkcs.conf /var/www/conf/${htName}.conf
        sed -i s/tlkcs/$htName/g /var/www/conf/${htName}.conf
	sed -i 8a"\\\tinclude /var/www/conf/${htName}.conf;" /var/www/conf/travelink.conf 
	killall nginx
	sleep 1
	/usr/local/m1905/nginx/sbin/nginx
	/usr/local/m1905/nginx_video/sbin/nginx
fi

dateNow=`date "+%Y-%m-%d %H:%M:%S"`
echo -e "Time:\t$dateNow From:\t$tarBagName To:\t$htName" | tee -a /var/www/$htName/updateHistory.txt /var/www/houtai.txt
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
                echo -e "hotelName:\t"$hotelName | tee -a /var/www/$htName/updateHistory.txt /var/www/houtai.txt
                echo -e "note:\t"$notes | tee -a /var/www/$htName/updateHistory.txt /var/www/houtai.txt
                echo -e "author:\t"$author | tee -a /var/www/$htName/updateHistory.txt /var/www/houtai.txt
                echo | tee -a /var/www/$htName/updateHistory.txt /var/www/houtai.txt
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
