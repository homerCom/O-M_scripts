#!/bin/bash
#2022-02-10
#lucaszhang@techtrex.com

#globle variable
webapp="/KiosoftApplications/WebApps"
serverapp="/KiosoftApplications/ServerApps"
logs_dir="/back/rsync/logs"
database_dir="/back/rsync/database"
code_dir="/back/rsync/code"

rsync_name=`/usr/bin/hostname`
rsync_user=`/usr/bin/hostname | awk -F '-' '{print$1}'`

#create dir
if [ ! -d "$logs_dir/laundry_portal" ] ;then
    mkdir -p /back/rsync/{code,database,logs}
    mkdir -p $logs_dir/{laundry_portal,value_code,reportServer,tokenServer,policyServer,tcp}
fi

#1.code backup
date_minute=`date +%Y%m%d%H%M`
rm -rf $code_dir/*
/usr/bin/rsync -avz $webapp/kiosk_laundry_portal $code_dir --exclude={'*.gz','*.zip','*.log'}
/usr/bin/rsync -avz $webapp/kiosk_value_code $code_dir --exclude={'*.gz','*.zip','*.log'}
/usr/bin/rsync -avz $webapp/kiosk_web_lcms $code_dir --exclude={'*.gz','*.zip','*.log'}
/usr/bin/rsync -avz $webapp/kiosk_web_rss $code_dir --exclude={'*.gz','*.zip','*.log'}
cd /back/rsync/code
zip -r web_code_$date_minute.zip *
find $code_dir -maxdepth 1 -mindepth 1 -type d | xargs -i rm -rf {}


#2.log backup
#清空目录，不然会有重复压缩问题
rm -rf $logs_dir/laundry_portal/*
rm -rf $logs_dir/value_code/*
rm -rf $logs_dir/reportServer/*
rm -rf $logs_dir/tokenServer/*
rm -rf $logs_dir/policyServer/*
rm -rf $logs_dir/tcp/*

/usr/bin/rsync -avz `find $webapp/kiosk_laundry_portal/application/logs/ -type f -name "*.log" -mtime +0 -o -name "*.log.gz"` $logs_dir/laundry_portal/
/usr/bin/rsync -avz `find $webapp/kiosk_value_code/application/logs/ -type f -name "*.log" -mtime +0 -o -name "*.log.gz"` $logs_dir/value_code/
/usr/bin/rsync -avz `find $serverapp/TTI_ReportServer/logs -type f -name "*.log.*" -mtime +0` $logs_dir/reportServer/
/usr/bin/rsync -avz `find /tmp/TokenServerLog/* -type f -mtime +0` $logs_dir/tokenServer/
/usr/bin/rsync -avz `find /var/www/policyServerLog/* -type f -mtime +0` $logs_dir/policyServer/

line=`ls $serverapp/ |grep tcp|wc -l`
dir=`ls $serverapp/ |grep tcp`
if [ $line -eq "1" ] ;then
    /usr/bin/rsync -avz `find $serverapp/$dir/logs/ -name "*.log.*" -mtime +0` $logs_dir/tcp/
fi

#for cleanstore
if [ -d $serverapp/TTI_Proxy ] ;then
	mkdir -p $logs_dir/proxy
	rm -rf $logs_dir/proxy/*
	/usr/bin/rsync -avz `find $serverapp/TTI_Proxy/logs -name "*.log.*" -mtime +0` $logs_dir/proxy/	
fi

#gzip logs
find $logs_dir/ -type f -exec gzip --rsyncable {} \;


#3.database backup
today=`/usr/bin/date +%w`
if [ -d /back/mysql/dir ] ;then
	if [ $today -eq "3" ] ;then
		find /back/mysql/dir/ -type f -mtime -1 -exec mv {} $database_dir/ \;
	elif [ $today -eq "4" ] ;then
		mv $database_dir/*.gz /back/mysql/dir/
	fi
fi

#write time to log
month=`/usr/bin/date '+%Y%m'`
day=`/usr/bin/date '+%Y-%m-%d %H:%M:%S'`
echo -e >> /var/log/rsync-$month.log
echo $day >> /var/log/rsync-$month.log

#rsync to remote backup server
/usr/bin/rsync -avz --password-file=/etc/rsync.password /back/rsync/* $rsync_user@20.83.180.26::$rsync_name >> /var/log/rsync-$month.log