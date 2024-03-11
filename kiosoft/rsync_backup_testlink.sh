#!/bin/bash
#2022-02-10
#lucaszhang@techtrex.com

#dir
webapp="/KiosoftApplications/WebApps"
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
percentage=$(($(nproc) * 10))

#log function
function log()
{
    log="$(date '+%Y-%m-%d %H:%M:%S') $@"
    echo $log >> /var/log/rsync-$month.log
}

#install cpulimit
status=`rpm -qa | grep cpulimit`
if [ $? -ne 0 ];then
    yum install -y cpulimit
fi

echo -e >> /var/log/rsync-$month.log
log "cpulimit $percentage"
log "Starting pack ..."
#create dir
if [ ! -d "$logs_dir/laundry_portal" ] ;then
    mkdir -p /back/rsync/{code,database,logs}
    mkdir -p $logs_dir/{laundry_portal,value_code,reportServer,tokenServer,policyServer,tcp}
fi

#1.code backup first day of a month
if [ $(date +%d) -eq 01 ]; then
	date_minute=`date +%Y%m%d%H%M`
	rm -rf $code_dir/*
	log "testlink code"
	cpulimit -l $percentage /usr/bin/rsync -avz $webapp/testlink $code_dir
	cd /back/rsync/code
	log "zip code"
	cpulimit -l $percentage zip -r web_code_$date_minute.zip *
	log "delete code"
	find $code_dir -maxdepth 1 -mindepth 1 -type d | xargs -i rm -rf {}
fi

#2.database backup
today=`/usr/bin/date +%w`
if [ -d /back/mysql/dir ] ;then
    log "start mv mysql"
    find /back/mysql/dir/ -type f -mtime -1 -exec mv {} $database_dir/ \;
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
log "Sending completed"

#Move the database file back to its original location
if [ -d /back/mysql/dir ] ;then
    log "start recovery mysql"
    mv $database_dir/*.gz /back/mysql/dir/
    log "recovery mysql complete"
fi
#
log "Backup complete"