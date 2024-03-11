#!/bin/bash
#author=lucaszhang@techtrex.com
#date:2022-07-01
#function:Delete log and backup files

#log directory
NGINX_BACK_LOG=/usr/local/nginx/logs/oldversion/
PORTAL_LOG=/KiosoftApplications/WebApps/kiosk_laundry_portal/application/logs/
Value_Code_LOG=/KiosoftApplications/WebApps/kiosk_value_code/application/logs/
REPORT_LOG=/KiosoftApplications/ServerApps/TTI_ReportServer/logs/
REPORT_BACKUP_LOG=/KiosoftApplications/ServerApps/oldversion/
WEB_BACKUP_LOG=/KiosoftApplications/WebApps/oldversion/
MYSQL_UPDATE_BACKUP=/back/mysql/
TOKENSERVER_LOG=/tmp/TokenServerLog/
PolicyServer_Log=/var/www/policyServerLog/

#压缩超过一天的日志
find $NGINX_BACK_LOG -name "*.log" -mtime +2 | xargs gzip
find $REPORT_LOG -name "*.log.2*" -mtime +1 | xargs gzip
find $TOKENSERVER_LOG -name "*.log" -mmin +1620 | xargs gzip

#删除超过60天的nginx日志
find $MYSQL_UPDATE_BACKUP -type d -name "ba*-*" | sort -nr | awk '{if (NR>=2){print $1}}' >> $MYSQL_UPDATE_BACKUP/delete.log
find $MYSQL_UPDATE_BACKUP -type d -name "ba*-*" | sort -nr | awk '{if (NR>=2){print $1}}'|xargs rm -rf
find $NGINX_BACK_LOG -type f -name -name '*.gz' -mtime +60 |xargs rm -rf

#Business log for 7 days
find $PORTAL_LOG -type f -name '*.log' -mtime +6 | xargs rm -rf
find $Value_Code_LOG -type f -name '*.log' -mtime +6 | xargs rm -rf
find $REPORT_LOG -type f -name '*.log.*' -mtime +6 | xargs rm -rf
find $REPORT_BACKUP_LOG -type f -name '*.log.*' -mtime +6 | xargs rm -rf
find $TOKENSERVER_LOG -type f -name '*.log' -mtime +6 -o -name "*.gz" -mtime +6 | xargs rm -rf
find $PolicyServer_Log -type f -name '*.log' -mtime +6 -o -name "*.gz" -mtime +6 | xargs rm -rf

#压缩 升级时备份的代码，超过1年删除
for dir in `find $WEB_BACKUP_LOG -maxdepth 1 -type d -mtime +1`
do
    cd $WEB_BACKUP_LOG
    name=`basename $dir`
    find $name/application/logs/ -name "log*.php" -o -name "*.log" |xargs rm -rf
    tar -zcvf $name.tar.gz $name
    rm -rf $name
done

find $WEB_BACKUP_LOG -maxdepth 1 -type f -name "*.gz" -mtime +365 | xargs -i rm -rf {}

#删除laundry_portal目录下的压缩文件
find /KiosoftApplications/WebApps/kiosk_laundry_portal/ -maxdepth 1 -type f -name "*.gz" -o -name "*.zip" -o -name "*.sql" | xargs rm -rf