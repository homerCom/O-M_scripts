#!/bin/bash
#2023-02-16
#lucaszhang@techtrex.com

date_minute=`date +%Y%m%d%H%M`
#1.下载脚本
if [ ! -f /script/rsync_backup.sh ] ;then
	wget http://download.vaststar.net/sh/rsync_backup.sh -P /script
	chmod +x /script/rsync_backup.sh
else
    mv /script/rsync_backup.sh /script/rsync_backup.sh-$date_minute
	rm -rf /script/rsync_backup.sh
	wget http://download.vaststar.net/sh/rsync_backup.sh -P /script
	chmod +x /script/rsync_backup.sh
	echo "/script/rsync_backup.sh  exists，updated."
fi
#2.生成12位随机密码
if [ -s /etc/rsync.password ] ;then
	echo "/etc/rsync.password exists and not empty!!!"
else
    
	key="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	num=${#key}
	pass=''
	for i in {1..12}
	do
		index=$[RANDOM%num]
		pass=$pass${key:$index:1}
	done
	echo $pass > /etc/rsync.password
	chmod 600 /etc/rsync.password
fi

#3.添加定时任务
cron=`crontab -l |grep "rsync_backup.sh" | wc -l`
if [ "$cron" -eq 0 ];
then
    echo -e >> /var/spool/cron/root
    echo "## rsync /back/rsync/ to remote backup server everyday" >> /var/spool/cron/root
    echo "0 1 * * * sh /script/rsync_backup.sh > /dev/null 2 >&1" >> /var/spool/cron/root
else
    echo "Cron for rsync_backup exists"
fi
