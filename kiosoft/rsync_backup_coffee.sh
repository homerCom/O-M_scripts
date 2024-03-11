#!/bin/bash
#2023-02-08
#lucaszhang@techtrex.com

#globle variable
webapp="/KiosoftApplications/WebApps"
logs_dir="/back/rsync/logs"
database_dir="/back/rsync/database"
code_dir="/back/rsync/code"

rsync_name=`/usr/bin/hostname`
rsync_user=`/usr/bin/hostname | awk -F '-' '{print$3}'`
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
echo -e >> /var/log/rsync-$month.log

function backup_database()
{
    local db_name_list=("coffee_back_end")
    local db_host="mariadb07-prod-market.mariadb.database.azure.com"
    local db_port="3306"
    local db_user="coffee_backup@mariadb07-prod-market"
    local db_password="coffee123?"
    local date_today=$(date +%Y%m%d%H%M)
    local backup_path="/back/rsync/database/"

    # Keep for 3 days
    find /back/rsync/database -type f -mtime +3 -exec rm {} \;

    # Set the CPU limit to the number of cores times 10
    local percentage=$(( $(nproc) * 10 ))

    for db_name in "${db_name_list[@]}"
    do
        # Limit the CPU usage during the backup process using cpulimit
        log "start mysqldump"
	cpulimit -l "$percentage" /usr/local/mysql/bin/mysqldump -u "$db_user" -p"$db_password" -h "$db_host" -P "$db_port" -R --opt "$db_name" > "${backup_path}${db_name}_${date_today}.sql"
        log "mysqldump complete"
	log "zip sql"
	cpulimit -l "$percentage" gzip "${backup_path}${db_name}_${date_today}.sql"
	log "zip complete"
    done
}

log "cpulimit $percentage"

#create dir
if [ ! -d "$logs_dir/coffee_backend" ] ;then
    mkdir -p /back/rsync/{code,database,logs}
    mkdir -p $logs_dir/coffee_backend
fi

log "Starting pack ..."
#1.code
log "pack code"
date_minute=`date +%Y%m%d%H%M`
rm -rf $code_dir/*
cpulimit -l $percentage /usr/bin/rsync -avzrtopg $webapp/kiosk_coffee_back_end $code_dir --exclude "*.log"
cpulimit -l $percentage /usr/bin/rsync -avzrtopg $webapp/kiosk_coffee_front_end_build $code_dir
cd $code_dir
cpulimit -l $percentage zip -r web_code_$date_minute.zip *
find $code_dir -maxdepth 1 -mindepth 1 -type d | xargs -i rm -rf {}
log "pack code complete"


#2.log
#清空目录，不然会有重复压缩问题
log "pack log"
rm -rf $logs_dir/coffee_backend/*

cpulimit -l $percentage /usr/bin/rsync -avzrtopg $webapp/kiosk_coffee_back_end/storage/logs/ $logs_dir/coffee_backend/

#gzip logs
log "start gzip logs..."
find $logs_dir/ -type f | xargs -i cpulimit -l $percentage gzip --rsyncable {}
log "gzip logs complete"

log "pack log complete"

#3.database
log "Start dump database"
backup_database
log "Database dump complete"

#write time to log
month=`/usr/bin/date '+%Y%m'`
log "Start Sending"
# 4.rsync to remote backup server
cpulimit -l $percentage /usr/bin/rsync -avz --password-file=/etc/rsync.password /back/rsync/* $rsync_user@$backupServer::$rsync_name >> /var/log/rsync-$month.log
log "Sending completed"

#
log "Backup complete"
