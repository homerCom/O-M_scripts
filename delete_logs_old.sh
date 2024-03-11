#!/bin/bash
#author=lucaszhang@techtrex.com
#date:2022-07-01
#function:Delete log and backup files

#log directory
NGINX_BACK_LOG=/usr/local/nginx/logs/oldversion/
PORTAL_LOG=/KiosoftApplications/WebApps/kiosk_laundry_portal/application/logs/
REPORT_LOG=/KiosoftApplications/ServerApps/TTI_ReportServer/logs/
REPORT_BACKUP_LOG=/KiosoftApplications/ServerApps/oldversion/
WEB_BACKUP_LOG=/KiosoftApplications/WebApps/oldversion/
MYSQL_UPDATE_BACKUP=/back/mysql/
TOKENSERVER_LOG=/tmp/TokenServerLog/

#删除超过60天的日志文件
find $MYSQL_UPDATE_BACKUP -type d -name "ba*-*" | sort -nr | awk '{if (NR>=2){print $1}}' >> $MYSQL_UPDATE_BACKUP/delete.log
find $MYSQL_UPDATE_BACKUP -type d -name "ba*-*" | sort -nr | awk '{if (NR>=2){print $1}}'|xargs rm -rf
find $PORTAL_LOG -type f -name '*.log' -mtime +60|xargs rm -rf
find $WEB_BACKUP_LOG -type f -name '*.log' -mtime +60|xargs rm -rf
find $REPORT_LOG -type f -name '*.log.*' -mtime +60|xargs rm -rf
find $REPORT_BACKUP_LOG -type f -name '*.log.*' -mtime +60|xargs rm -rf
find $NGINX_BACK_LOG -type f -name '*.log' -mtime +60|xargs rm -rf
find $TOKENSERVER_LOG -type f -name '*.log' -mtime +60|xargs rm -rf
