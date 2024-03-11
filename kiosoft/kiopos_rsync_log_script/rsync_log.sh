#!/bin/bash
#2024-02-18
#rsyn
#rsync
rsync_name=`/usr/bin/hostname`
rsync_user=`/usr/bin/hostname | awk -F '-' '{print$3}'`
backupServer="backup.kiosoft.com"
#log month
month=`/usr/bin/date '+%Y%m'`
#cpu limit percentage by cpu cores
percentage=$(($(nproc) * 10))

TodayDate=`date +%Y%m%d`
#api
find /KiosoftApplications/WebApps/dataapp/kpos/logs/api/error -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/api/error/log-*.gz /back/rsync/logs/api/error/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/api/file -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/api/file/log-*.gz /back/rsync/logs/api/file/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/api/info -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/api/info/log-*.gz /back/rsync/logs/api/info/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/api/warn -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/api/warn/log-*.gz /back/rsync/logs/api/warn/
cd /back/rsync/logs/api
tar zcvf api_log_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/api/api_log.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/api/api_log.log
tar zcvf log_debug_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/api/log_debug.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/api/log_debug.log
tar zcvf log_error_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/api/log_error.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/api/log_error.log
tar zcvf log_file_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/api/log_file.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/api/log_file.log
tar zcvf log_info_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/api/log_info.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/api/log_info.log
tar zcvf log_warn_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/api/log_warn.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/api/log_warn.log
cpulimit -l $percentage /usr/bin/rsync -avz --password-file=/etc/rsync.password /back/rsync/* $rsync_user@$backupServer::$rsync_name >> /var/log/rsync-$month.log
rm -rf api_log_$TodayDate.tar.gz log_debug_$TodayDate.tar.gz log_error_$TodayDate.tar.gz log_file_$TodayDate.tar.gz log_info_$TodayDate.tar.gz log_warn_$TodayDate.tar.g /back/rsync/logs/api/error/
rm -rf  /back/rsync/logs/api/error/log-*.gz
rm -rf  /back/rsync/logs/api/file/log-*.gz
rm -rf  /back/rsync/logs/api/info/log-*.gz
rm -rf  /back/rsync/logs/api/warn/log-*.gz

#canal
find /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/error -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/error/log-*.gz /back/rsync/logs/canal/error/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/file -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/file/log-*.gz /back/rsync/logs/canal/file/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/info -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/info/log-*.gz /back/rsync/logs/canal/info/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/warn -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/warn/log-*.gz /back/rsync/logs/canal/warn/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/debug -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/debug/log-*.gz /back/rsync/logs/canal/debug/

cd /back/rsync/logs/canal/

tar zcvf canal_log_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/canal_log.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/canal_log.log
tar zcvf log_debug_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/log_debug.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/log_debug.log
tar zcvf log_error_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/log_error.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/log_error.log
tar zcvf log_file_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/log_file.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/log_file.log
tar zcvf log_info_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/log_info.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/log_info.log
tar zcvf log_warn_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/log_warn.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/canal/log_warn.log

cpulimit -l $percentage /usr/bin/rsync -avz --password-file=/etc/rsync.password /back/rsync/* $rsync_user@$backupServer::$rsync_name >> /var/log/rsync-$month.log

rm -rf canal_log_$TodayDate.tar.gz log_debug_$TodayDate.tar.gz log_error_$TodayDate.tar.gz log_file_$TodayDate.tar.gz log_info_$TodayDate.tar.gz log_warn_$TodayDate.tar.gz
rm -rf  /back/rsync/logs/canal/error/log-*.gz
rm -rf  /back/rsync/logs/canal/file/log-*.gz
rm -rf  /back/rsync/logs/canal/info/log-*.gz
rm -rf  /back/rsync/logs/canal/warn/log-*.gz
rm -rf  /back/rsync/logs/canal/debug/log-*.gz




#gateway
find /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/error -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/error/log-*.gz /back/rsync/logs/gateway/error/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/file -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/file/log-*.gz /back/rsync/logs/gateway/file/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/info -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/info/log-*.gz /back/rsync/logs/gateway/info/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/warn -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/warn/log-*.gz /back/rsync/logs/gateway/warn/


cd /back/rsync/logs/gateway/

tar zcvf gateway_log_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/gateway_log.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/gateway_log.log
tar zcvf log_debug_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/log_debug.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/log_debug.log
tar zcvf log_error_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/log_error.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/log_error.log
tar zcvf log_file_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/log_file.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/log_file.log
tar zcvf log_info_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/log_info.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/log_info.log
tar zcvf log_warn_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/log_warn.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/gateway/log_warn.log

cpulimit -l $percentage /usr/bin/rsync -avz --password-file=/etc/rsync.password /back/rsync/* $rsync_user@$backupServer::$rsync_name >> /var/log/rsync-$month.log

rm -rf gateway_log_$TodayDate.tar.gz log_debug_$TodayDate.tar.gz log_error_$TodayDate.tar.gz log_file_$TodayDate.tar.gz log_info_$TodayDate.tar.gz log_warn_$TodayDate.tar.gz
rm -rf  /back/rsync/logs/gateway/error/log-*.gz
rm -rf  /back/rsync/logs/gateway/file/log-*.gz
rm -rf  /back/rsync/logs/gateway/info/log-*.gz
rm -rf  /back/rsync/logs/gateway/warn/log-*.gz


#report

find /KiosoftApplications/WebApps/dataapp/kpos/logs/report/error -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/report/error/log-*.gz /back/rsync/logs/report/error/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/report/file -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/report/file/log-*.gz /back/rsync/logs/report/file/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/report/info -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/report/info/log-*.gz /back/rsync/logs/report/info/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/report/warn -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/report/warn/log-*.gz /back/rsync/logs/report/warn/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/report/debug -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/report/debug/log-*.gz /back/rsync/logs/report/debug/


cd /back/rsync/logs/report/

tar zcvf report_log_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/report/report_log.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/report/report_log.log
tar zcvf log_debug_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/report/log_debug.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/report/log_debug.log
tar zcvf log_error_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/report/log_error.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/report/log_error.log
tar zcvf log_file_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/report/log_file.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/report/log_file.log
tar zcvf log_info_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/report/log_info.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/report/log_info.log
tar zcvf log_warn_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/report/log_warn.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/report/log_warn.log

cpulimit -l $percentage /usr/bin/rsync -avz --password-file=/etc/rsync.password /back/rsync/* $rsync_user@$backupServer::$rsync_name >> /var/log/rsync-$month.log

rm -rf report_log_$TodayDate.tar.gz log_debug_$TodayDate.tar.gz log_error_$TodayDate.tar.gz log_file_$TodayDate.tar.gz log_info_$TodayDate.tar.gz log_warn_$TodayDate.tar.gz
rm -rf  /back/rsync/logs/report/error/log-*.gz
rm -rf  /back/rsync/logs/report/file/log-*.gz
rm -rf  /back/rsync/logs/report/info/log-*.gz
rm -rf  /back/rsync/logs/report/warn/log-*.gz
rm -rf  /back/rsync/logs/report/debug/log-*.gz

#schedule

find /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/error -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/error/log-*.gz /back/rsync/logs/schedule/error/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/file -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/file/log-*.gz /back/rsync/logs/schedule/file/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/info -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/info/log-*.gz /back/rsync/logs/schedule/info/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/warn -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/warn/log-*.gz /back/rsync/logs/schedule/warn/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/debug -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/debug/log-*.gz /back/rsync/logs/schedule/debug/


cd /back/rsync/logs/schedule/

tar zcvf schedule_log_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/schedule_log.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/schedule_log.log
tar zcvf log_debug_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/log_debug.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/log_debug.log
tar zcvf log_error_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/log_error.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/log_error.log
tar zcvf log_file_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/log_file.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/log_file.log
tar zcvf log_info_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logsschedulet/log_info.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/log_info.log
tar zcvf log_warn_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/log_warn.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/schedule/log_warn.log

cpulimit -l $percentage /usr/bin/rsync -avz --password-file=/etc/rsync.password /back/rsync/* $rsync_user@$backupServer::$rsync_name >> /var/log/rsync-$month.log

rm -rf schedule_log_$TodayDate.tar.gz log_debug_$TodayDate.tar.gz log_error_$TodayDate.tar.gz log_file_$TodayDate.tar.gz log_info_$TodayDate.tar.gz log_warn_$TodayDate.tar.gz
rm -rf  /back/rsync/logs/schedule/error/log-*.gz
rm -rf  /back/rsync/logs/schedule/file/log-*.gz
rm -rf  /back/rsync/logs/schedule/info/log-*.gz
rm -rf  /back/rsync/logs/schedule/warn/log-*.gz
rm -rf  /back/rsync/logs/schedule/debug/log-*.gz

#system


find /KiosoftApplications/WebApps/dataapp/kpos/logs/system/error -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/system/error/log-*.gz /back/rsync/logs/system/error/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/system/file -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/system/file/log-*.gz /back/rsync/logs/system/file/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/system/info -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/system/info/log-*.gz /back/rsync/logs/system/info/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/system/warn -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/system/warn/log-*.gz /back/rsync/logs/system/warn/
find /KiosoftApplications/WebApps/dataapp/kpos/logs/system/debug -name "log-*.log" -mtime +1 |xargs gzip -f
mv /KiosoftApplications/WebApps/dataapp/kpos/logs/system/debug/log-*.gz /back/rsync/logs/system/debug/


cd /back/rsync/logs/system/

tar zcvf system_log_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/system/system_log.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/system/system_log.log
tar zcvf log_debug_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/system/log_debug.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/system/log_debug.log
tar zcvf log_error_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/system/log_error.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/system/log_error.log
tar zcvf log_file_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/system/log_file.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/system/log_file.log
tar zcvf log_info_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logsschedulet/log_info.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/system/log_info.log
tar zcvf log_warn_$TodayDate.tar.gz /KiosoftApplications/WebApps/dataapp/kpos/logs/system/log_warn.log
echo /dev/null > /KiosoftApplications/WebApps/dataapp/kpos/logs/system/log_warn.log

cpulimit -l $percentage /usr/bin/rsync -avz --password-file=/etc/rsync.password /back/rsync/* $rsync_user@$backupServer::$rsync_name >> /var/log/rsync-$month.log

rm -rf system_log_$TodayDate.tar.gz log_debug_$TodayDate.tar.gz log_error_$TodayDate.tar.gz log_file_$TodayDate.tar.gz log_info_$TodayDate.tar.gz log_warn_$TodayDate.tar.gz
rm -rf  /back/rsync/logs/system/error/log-*.gz
rm -rf  /back/rsync/logs/system/file/log-*.gz
rm -rf  /back/rsync/logs/system/info/log-*.gz
rm -rf  /back/rsync/logs/system/warn/log-*.gz
rm -rf  /back/rsync/logs/system/debug/log-*.gz
