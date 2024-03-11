#!/bin/bash
#功能查询后台多余apk

houtai=$1
[ $# -ne 1 ] && echo "请输入正确的后台名称" &&exit 0

#检查后台是否存在
ls /var/www/$houtai > /dev/null 2>&1
[ $? -ne 0 ]&&echo "$houtai dose not exists!"&&exit

dbUser=`cat /var/www/$houtai/config.php |awk -F ''\' '/DB_USER/{print $4}'`
dbPasswd=`cat /var/www/$houtai/config.php |awk -F ''\' '/DB_PWD/{print $4}'`

#查询多余apk
mysql -u$dbUser -p$dbPasswd -e "use $houtai;select apk_name from h_apk;"|sed 1d >/opt/baoliu.txt

find /var/www/$houtai/admin/images/apk/ > /opt/all.txt
sed -i '1d' /opt/all.txt

if [ -f /opt/shanchu.txt ];then
	rm -rf /opt/shanchu.txt
fi

while read line
do
	apk=`echo $line |awk -F '/' '{print $NF}'`
	num=`grep $apk /opt/baoliu.txt | wc -l`
	if [ $num -eq 0 ];then
		echo $line >> /opt/shanchu.txt
	fi
done < /opt/all.txt

#查询多余视频及文件
mysql -u$dbUser -p$dbPasswd -e "use $houtai;select music_addr from h_music;"|sed 1d >/opt/baoliu.txt

find /var/www/$houtai/admin/images/music/|sed 1d > /opt/all.txt


while read line
do
        music=`echo $line |awk -F '/' '{print $NF}'`
        num=`grep $music /opt/baoliu.txt | wc -l`
        if [ $num -eq 0 ];then
                echo $line >> /opt/shanchu.txt
        fi
done < /opt/all.txt

echo "请确认后，再执行 cat /opt/shanchu.txt | xargs rm -rfv"
