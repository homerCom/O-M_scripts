#!/bin/bash
#date:20220701
#function:deploy crontab

[ $UID -ne 0 ]&&echo "Please run this script as root user"&&exit 1

wget -q -N -P /script/ 47.107.31.18/sh/delete_logs.sh
chmod +x /script/delete_logs.sh
echo "Script has been saved to /script/delete_logs.sh"

cron=`crontab -l|grep "/script/delete_logs.sh"|wc -l`
if [ $cron -eq 0 ];then
	crontab -l > /tmp/cron
	echo "" >> /tmp/cron
	echo "#delete logs" >> /tmp/cron
	echo "0  2  *  *  *  sh /script/delete_logs.sh > /dev/null 2 >&1" >> /tmp/cron
	crontab /tmp/cron
	rm -f /tmp/cron
	echo "Crontab installed successfully. niubi"
else
	echo "delete_logs already exists in crontab"
fi

rm $0
