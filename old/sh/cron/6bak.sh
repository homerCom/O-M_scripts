#!/bin/bash
# 备份后台和数据库
PATH=/bin:/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

IP=`ip a | awk '/10\.8\./{print $2}'`
[ -z $IP ]&&echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] \"IP error\"" >> /var/log/bak.log&&exit 1
[ ! -d /tmp/backup/ ]&&mkdir -p /tmp/backup/
timeNow=`date +%Y%m%d`

ls /var/www/ | grep cs$ | while read houtai
do
	echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] \"rsync $houtai begin\"" >> /var/log/bak.log
        dbuser=`cat /var/www/$houtai/config.php | awk -F "'" '/DB_USER/{print $4}'`
        dbname=`cat /var/www/$houtai/config.php | awk -F "'" '/DB_NAME/{print $4}'`
        dbpwd=`cat /var/www/$houtai/config.php | awk -F "'" '/DB_PWD/{print $4}'`

	# share
	cat /var/www/$houtai/admin/template/admin/login.html | grep -q 8888
	# 2.0
        if [ $? -eq 0 ];then
                find /var/www/share/ -type d  | awk -F 'www' '{print $2}' | xargs -I {} mkdir -p /tmp/backup/{}
                rsync -vzrtopgL /var/www/share/tv/ /tmp/backup/share/tv/
                mysql -u$dbuser -p$dbpwd -e 'select apk_name from '$dbname'.h_apk;' | sed 1d | xargs -I {} cp /var/www/share/hvupdate/{} /tmp/backup/share/hvupdate/
                mysql -u$dbuser -p$dbpwd -e 'select music_addr from '$dbname'.h_music;' | sed 1d | xargs -I {} cp -r /var/www/{} /tmp/backup/{}
                rsync -vzrtopgL --port=2345 --password-file=/etc/rsync.password /tmp/backup/ xiaoshuai@update.xshuai.com::backup/$IP/
		echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] 2.0 \"rsync share complate\"" >> /var/log/bak.log
        fi

        # db
        mysqldump -u$dbuser -p$dbpwd $dbname>/tmp/backup/$houtai-$timeNow.sql
	echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] \"mysqldump $dbname to $houtai-$timeNow.sql success\"" >> /var/log/bak.log
	rsync -vzrtopgL --port=2345 --password-file=/etc/rsync.password /tmp/backup/ xiaoshuai@update.xshuai.com::backup/$IP/
	echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] \"rsync $houtai-$timeNow.sql  complate\"" >> /var/log/bak.log
	
        # houtai
        rsync -vzrtopgL  --exclude="2018081111232298666.mp4" --exclude="2018081111202856240.mov" --exclude="2018081111140949323.mp4" --exclude="2018082114113484233.mp4" --exclude="2018081111153169917.mp4" --exclude="2018081111150663413.wmv" --exclude="log/*" --exclude="ubc/*" --exclude="upgradeFeedback.txt" --port=2345 --password-file=/etc/rsync.password /var/www/$houtai/ xiaoshuai@update.xshuai.com::backup/$IP/$houtai/
	echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] \"rsync $houtai complate\"" >> /var/log/bak.log
done
