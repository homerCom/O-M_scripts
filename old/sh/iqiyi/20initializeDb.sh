#!/bin/bash
# 脚本名：20initializeDb_centos67.sh
# 功能：清空一些数据表
# 格式：脚本名 后台名

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 1 ]&&echo "参数不正确"&&exit 1
[ ! -d /var/www/$1 ]&&echo "相应后台不存在"&&exit 1

htname=$1
dbname=`awk -F "'" '/DB_NAME/{print $4}' /var/www/$htname/config.php`
dbPassword=`awk -F "'" '/DB_PWD/{print $4}' /var/www/$htname/config.php`
txtUrl=`find /var/www/$htname/ -maxdepth 1 -iname updatehistory.txt`

echo "===================================================">>$txtUrl
echo "`date` 初始化数据库$htname">>$txtUrl

mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc d_ads_task;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table d_ads_task;"&&echo "truncate table d_ads_task SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc d_collect_ads;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table d_collect_ads;"&&echo "truncate table d_collect_ads SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc d_collect_apk;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table d_collect_apk;"&&echo "truncate table d_collect_apk SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc d_heartbeat;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table d_heartbeat;"&&echo "truncate table d_heartbeat SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc d_movietask;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table d_movietask;"&&echo "truncate table d_movietask SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc d_pricetask;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table d_pricetask;"&&echo "truncate table d_pricetask SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc d_upgradedata;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table d_upgradedata;"&&echo "truncate table d_upgradedata SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_ads;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_ads;"&&echo "truncate table h_ads SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_adsalive;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_adsalive;"&&echo "truncate table h_adsalive SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_adslog;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_adslog;"&&echo "truncate table h_adslog SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_downloadlog;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_downloadlog;"&&echo "truncate table h_downloadlog SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_flog;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_flog;"&&echo "truncate table h_flog SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_guest;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_guest;"&&echo "truncate table h_guest SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_message;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_message;"&&echo "truncate table h_message SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_movieflog;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_movieflog;"&&echo "truncate table h_movieflog SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_movierate;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_movierate;"&&echo "truncate table h_movierate SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_movieupdate;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_movieupdate;"&&echo "truncate table h_movieupdate SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_note;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_note;"&&echo "truncate table h_note SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_notice;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_notice;"&&echo "truncate table h_notice SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_order;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_order;"&&echo "truncate table h_order SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_ordernote;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_ordernote;"&&echo "truncate table h_ordernote SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_rooms;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_rooms;"&&echo "truncate table h_rooms SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_rooms_conf;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_rooms_conf;"&&echo "truncate table h_rooms_conf SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_rooms_groups;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_rooms_groups;"&&echo "truncate table h_rooms_groups SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_rooms_platform;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_rooms_platform;"&&echo "truncate table h_rooms_platform SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_rooms_state;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_rooms_state;"&&echo "truncate table h_rooms_state SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_seecounts;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_seecounts;"&&echo "truncate table h_seecounts SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_stafflog;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_stafflog;"&&echo "truncate table h_stafflog SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_update_data;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_update_data;"&&echo "truncate table h_update_data SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_update_log;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_update_log;"&&echo "truncate table h_update_log SUCCESS!"|tee -a $txtUrl
mysql -uxiaoshuai -p$dbPassword -e "use $htname;desc h_update_version;" >/dev/null 2>&1
[ $? -eq 0 ]&&mysql -uxiaoshuai -p$dbPassword -e "use $htname;truncate table h_update_version;"&&echo "truncate table h_update_version SUCCESS!"|tee -a $txtUrl
rm -rfv /var/www/$htname/admin/updatedata/*
echo "===================================================">>$txtUrl
echo "清空相关数据库结束"
