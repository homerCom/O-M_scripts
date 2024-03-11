#!/bin/bash
#2023-03-28
#lucaszhang@techtrex.com

# Database information
laundry=`cat /KiosoftApplications/WebApps/kiosk_laundry_portal/application/config/database.php |grep laundry|grep database|grep -v portal|grep -v mariadb|awk -F "'" '{print$6}'`
laundry_portal=`cat /KiosoftApplications/WebApps/kiosk_laundry_portal/application/config/database.php |grep laundry_portal|grep database|grep -v mariadb|awk -F "'" '{print$6}'`
value_code=`cat /KiosoftApplications/WebApps/kiosk_laundry_portal/application/config/database.php |grep value_code|grep database|grep -v mariadb|awk -F "'" '{print$6}'`
web_lcms=`cat /KiosoftApplications/WebApps/kiosk_laundry_portal/application/config/database.php |grep web_lcms|grep database|grep -v mariadb|awk -F "'" '{print$6}'`
db_name_list=($laundry $laundry_portal $value_code $web_lcms)
db_host=`cat /KiosoftApplications/WebApps/kiosk_laundry_portal/application/config/database.php |grep laundry|grep hostname |awk -F "'" '{print $6}'`
db_port=`cat /KiosoftApplications/WebApps/kiosk_laundry_portal/application/config/database.php |grep laundry|grep -w port |awk -F "'" '{print $6}'`
db_user=`cat /KiosoftApplications/WebApps/kiosk_laundry_portal/application/config/database.php|grep username|grep laundry | awk -F "'" '{print $6}'`
db_password=`cat /KiosoftApplications/WebApps/kiosk_laundry_portal/application/config/database.php|grep password|grep laundry | awk -F "'" '{print $6}'`
date_today=`date +%Y%m%d%H%M`

#Backup file expiration time
delte_date=30

# Backup file path
backup_path=/back/mysql/dir/

# Set the CPU limit to the number of cores times 10
percentage=$(($(nproc) * 10))

# Backup each database with CPU limit
for db_name in "${db_name_list[@]}"
do
    # Limit the CPU usage during the backup process using cpulimit
    cpulimit -l "${percentage}" mysqldump -u "${db_user}" -p"${db_password}" -h "${db_host}" -P "${db_port}" -R --opt "${db_name}" > "${backup_path}${db_name}_${date_today}.sql"
    cpulimit -l "${percentage}" gzip ${backup_path}${db_name}_${date_today}.sql
done

# Delete backup files older than 30 days
find $backup_path -type f -name "*.sql.gz" -mtime +$delte_date -exec rm {} \;