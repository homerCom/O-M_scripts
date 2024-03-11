#!/bin/bash
#功能：查询后台多余apk、开机视频、xml文件
#用法：脚本名 后台名
#author：Homer

[ $# -ne 1 ]&&echo "参数错误，请重新输入"&&exit 1
[ ! -d /var/www/$1 ]&&echo "后台不存在，请检查"&&exit 1
htname=$1
dbuser=`awk -F "'" '/DB_USER/{print $4}' /var/www/$htname/config.php`
dbpwd=`awk -F "'" '/DB_PWD/{print $4}' /var/www/$htname/config.php`
#检测文本是否已存在，若存在则删除
if [ -f /opt/delete.txt ];then
	rm -rf /opt/delete.txt
	rm -rf /opt/hold.txt
	rm -rf /opt/all.txt
fi
mysql -u$dbuser -p$dbpwd -e 'select apk_name from '$htname'.h_apk;'|sed 1d|awk -F '/' '{print $3}' >> /opt/hold.txt
mysql -u$dbuser -p$dbpwd -e 'select music_addr from '$htname'.h_music;'|sed 1d|awk -F '/' '{print $3}' >> /opt/hold.txt
find /var/www/$htname/admin/images/apk/ -type f  >> /opt/all.txt
find /var/www/$htname/admin/images/music/ -type f >> /opt/all.txt
cat /opt/all.txt |while read line
do
	apk=`echo $line|awk -F '/' '{print $NF}'`
	flag=`grep $apk /opt/hold.txt|wc -l`
	if [ $flag -eq 0 ];then
		echo $line >> /opt/delete.txt
	fi
done
if [ ! -f /opt/delete.txt ];then
        echo "该后台无多余文件！"
else
	echo "请确认要删除的文件后，再执行 cat /opt/delete.txt | xargs rm -rfv"
fi
