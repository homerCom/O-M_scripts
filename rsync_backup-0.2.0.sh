#!/bin/bash
#2022-02-10
#lucaszhang@techtrex.com

#dir
webapp="/KiosoftApplications/WebApps"
serverapp="/KiosoftApplications/ServerApps"
logs_dir="/back/rsync/logs"
database_dir="/back/rsync/database"
code_dir="/back/rsync/code"
#rsync
rsync_name=`/usr/bin/hostname`
rsync_user=`/usr/bin/hostname | awk -F '-' '{print$1}'`
backupServer="backup.kiosoft.com"
#log month
month=`/usr/bin/date '+%Y%m'`
#cpu limit percentage by cpu cores
core=`cat /proc/cpuinfo | grep "processor" |wc -l`
percentage=`expr $core \* 5`

#
database_empty=1
code_empty=1
log_empty=1
rsync_sucess=1

#log function
function log()
{
    log="$(date '+%Y-%m-%d %H:%M:%S') $@"
    echo $log >> /var/log/rsync-$month.log
}

#install cpulimit
status=`rpm -qa | grep cpulimit`
if [ $? -ne 0 ];then
	yum install -y epel-release
    yum install -y cpulimit
fi

log "cpulimit $percentage"

echo -e >> /var/log/rsync-$month.log
log "Starting pack ..."
#create dir
if [ ! -d "$logs_dir/laundry_portal" ] ;then
    mkdir -p /back/rsync/{code,database,logs}
    mkdir -p $logs_dir/{laundry_portal,value_code,reportServer,tokenServer,policyServer,tcp}
fi

#1.code backup
date_minute=`date +%Y%m%d%H%M`
rm -rf $code_dir/*
log "laundry code"
cpulimit -l $percentage /usr/bin/rsync -avz $webapp/kiosk_laundry_portal $code_dir --exclude={'*.gz','*.zip','*.log','*.sql'}
log "value_code code"
cpulimit -l $percentage /usr/bin/rsync -avz $webapp/kiosk_value_code $code_dir --exclude={'*.gz','*.zip','*.log'}
log "web_lcms code"
cpulimit -l $percentage /usr/bin/rsync -avz $webapp/kiosk_web_lcms $code_dir --exclude={'*.gz','*.zip','*.log'}
log "web_rss code"
cpulimit -l $percentage /usr/bin/rsync -avz $webapp/kiosk_web_rss $code_dir --exclude={'*.gz','*.zip','*.log'}
cd /back/rsync/code
log "zip code"
cpulimit -l $percentage zip -r web_code_$date_minute.zip *
log "delete code"
find $code_dir -maxdepth 1 -mindepth 1 -type d | xargs -i rm -rf {}


#2.log backup
#Empty the directory, otherwise there will be repeated compression problems
rm -rf $logs_dir/laundry_portal/*
rm -rf $logs_dir/value_code/*
rm -rf $logs_dir/reportServer/*
rm -rf $logs_dir/tokenServer/*
rm -rf $logs_dir/policyServer/*
rm -rf $logs_dir/tcp/*

log "laundry log"
cpulimit -l $percentage /usr/bin/rsync -avz `find $webapp/kiosk_laundry_portal/application/logs/ -type f -name "*.log" -mmin +60 -mmin -1500` $logs_dir/laundry_portal/
log "value_code log"
cpulimit -l $percentage /usr/bin/rsync -avz `find $webapp/kiosk_value_code/application/logs/ -type f -name "*.log" -mmin +60 -mmin -1500` $logs_dir/value_code/
log "report log"
cpulimit -l $percentage /usr/bin/rsync -avz `find $serverapp/TTI_ReportServer/logs -type f -name "*.log.*" -mmin +60 -mmin -1500` $logs_dir/reportServer/
log "tokenserver log"
cpulimit -l $percentage /usr/bin/rsync -avz `find /tmp/TokenServerLog/* -type f -mmin +60 -mmin -1500` $logs_dir/tokenServer/
log "policy log"
cpulimit -l $percentage /usr/bin/rsync -avz `find /var/www/policyServerLog/* -type f -mmin +60 -mmin -1500` $logs_dir/policyServer/

line=`ls $serverapp/ |grep tcp|wc -l`
dir=`ls $serverapp/ |grep tcp`
if [ $line -eq "1" ] ;then
   log "tcp log"
   cpulimit -l $percentage /usr/bin/rsync -avz `find $serverapp/$dir/logs/ -name "*.log.*" -mmin +60 -mmin -1500` $logs_dir/tcp/
fi

#for cleanstore
if [ -d $serverapp/TTI_Proxy ] ;then
        mkdir -p $logs_dir/proxy
        rm -rf $logs_dir/proxy/*
        log "proxy log"
        cpulimit -l $percentage /usr/bin/rsync -avz `find $serverapp/TTI_Proxy/logs -name "*.log.*" -mmin +60 -mmin -1500` $logs_dir/proxy/
fi

#gzip logs
log "start gzip logs..."
find $logs_dir/ -type f | xargs -i cpulimit -l $percentage gzip --rsyncable {}
log "gzip logs complete"

#3.database backup
today=`/usr/bin/date +%w`
if [ -d /back/mysql/dir ] ;then
        if [ $today -eq "3" ] ;then
                log "start mv mysql"
                find /back/mysql/dir/ -type f -mtime -1 -exec mv {} $database_dir/ \;
                log "mysql mv complete"
        fi
fi
log "Packaging complete"

#Wait for random seconds to avoid server congestion
function randsecond(){
  min=$1
  max=$(($2-$min+1))
  num=$(date +%s%N)
  echo $(($num%$max+$min))
}

second=$(randsecond 1 3600)
log "Sleep for $second seconds"
sleep $second

#write time to log
log "Start sending"
#rsync to remote backup server
cpulimit -l $percentage /usr/bin/rsync -avz --password-file=/etc/rsync.password /back/rsync/* $rsync_user@$backupServer::$rsync_name >> /var/log/rsync-$month.log
[ $? -ne 0 ] && rsync_sucess=0
log "Sending completed"

#Move the database file back to its original location
if [ $today -eq "3" ] ;then
    log "start recovery mysql"
    mv $database_dir/*.gz /back/mysql/dir/
    log "recovery mysql complete"
    [ `du -sh /back/rsync/database|awk '{print$1}'` == "0" ] && database_empty=0
fi
#
[ `du -sh /back/rsync/code|awk '{print$1}'` == "0" ] && code_empty=0
[ `du -sh /back/rsync/logs|awk '{print$1}'` == "0" ] && logs_empty=0
if [ $rsync_sucess -eq 0 || $database_empty -eq 0 || $code_empty -eq 0 || $logs_empty -eq 0 ];then
    echo "$(date '+%Y-%m-%d') Backup failed" >> /var/log/rsync-$month.log
else
    echo "$(date '+%Y-%m-%d') Backup succeeded" >> /var/log/rsync-$month.log
fi
