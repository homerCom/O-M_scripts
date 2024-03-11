#!/bin/bash
# 部署清理任务

wget http://219.146.255.198:8098/share/zhang/scripts/11clean_log.sh -P /var/www/sh

chmod 777 /var/www/sh/11clean_log.sh

echo -e "\n#每月一号凌晨清理日志文件
0 0 1 * *	/bin/bash /var/www/sh/11clean_log.sh >> /dev/null 2>&1" >> /var/spool/cron/root
