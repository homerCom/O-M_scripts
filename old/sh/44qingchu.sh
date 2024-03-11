#!/bin/bash
# 2.0，3.0通用
# 删除多余文件（1，多余apk 2，多余视频 3，upgradeFeedback.txt 4，清空/var/www/tlkcs/log/目录 5，清空/var/www/tlkcs/ubc/目录 6，清空多余数据表（h_downloadlog，d_collect_apk，d_heartbeat））
# 
# 
[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1

ls /var/www/ | grep cs$ | while read htname
do
        echo $htname
	dbuser=`awk -F "'" '/DB_USER/{print $4}' /var/www/$htname/config.php`
	dbpwd=`awk -F "'" '/DB_PWD/{print $4}' /var/www/$htname/config.php`

	[ ! -d /var/www/$htname/empty/ ]&&mkdir /var/www/$htname/empty/
	[ -d /var/www/$htname/log/ ]&&echo "删除log下文件"&&du -sh /var/www/$htname/log/&&rsync -a --delete /var/www/$htname/empty/ /var/www/$htname/log/
	[ -d /var/www/$htname/ubc/ ]&&echo "删除ubc下文件"&&du -sh /var/www/$htname/ubc/&&rsync -a --delete /var/www/$htname/empty/ /var/www/$htname/ubc/

	echo "清空h_downloadlog，d_collect_apk，d_heartbeat三个表"
	mysql -u$dbuser -p$dbpwd $htname -e "truncate h_downloadlog;truncate d_collect_apk;truncate d_heartbeat;"
        grep -q 8888 /var/www/$htname/admin/template/admin/login.html
        if [ $? -eq 0 ];then
		echo "$htname 2.0"
		rsync -avL xiaoshuai@10.8.0.170::tlkcs2/ /var/www/$htname/ --password-file=/etc/rsync.password
	else
		echo "$htname 3.0"
		# 服务器上所有apk
		ls /var/www/$htname/admin/images/apk/ > /tmp/houtaiApk.txt
		# 应该保留apk
		mysql -u$dbuser -p$dbpwd -e "use $htname;select apk_name from h_apk;" | sed 1d | awk -F '/' '{print $NF}' > /tmp/dbApk.txt
		# 服务器上所有music
		ls /var/www/$htname/admin/images/music/ > /tmp/houtaiMusic.txt
		# 应该保留的视频
		mysql -u$dbuser -p$dbpwd -e "use $htname;select music_addr from h_music;" | sed 1d | awk -F '/' '{print $NF}' > /tmp/dbMusic.txt
		# 应该保留的人文大赏视频
		mysql -u$dbuser -p$dbpwd -e "use $htname;select video from h_rwnews;" | sed 1d | awk -F '/' '{print $NF}' >> /tmp/dbMusic.txt

		echo "应该保留的apk："
		sort /tmp/houtaiApk.txt /tmp/dbApk.txt | uniq -d
		echo
		echo "以下多余的apk被删除。。。"
		sort /tmp/houtaiApk.txt /tmp/dbApk.txt /tmp/dbApk.txt | uniq -u | xargs -I {} rm -rfv /var/www/$htname/admin/images/apk/{}
		echo
		echo "应该保留的music："
		sort /tmp/houtaiMusic.txt /tmp/dbMusic.txt | uniq -d
		echo
		echo "以下多余的music被删除。。。"
		sort /tmp/houtaiMusic.txt /tmp/dbMusic.txt /tmp/dbMusic.txt | uniq -u  | xargs -I {} rm -rfv /var/www/$htname/admin/images/music/{}
		echo "删除upgradeFeedback.txt"
		[ -f /var/www/$htname/upgradeFeedback.txt ]&&du -sh /var/www/$htname/upgradeFeedback.txt&&rm -rfv /var/www/$htname/upgradeFeedback.txt

		# 同步后台
		rsync -avL xiaoshuai@10.8.0.170::tlkcs3/ /var/www/$htname/ --password-file=/etc/rsync.password
	fi
done
