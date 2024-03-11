#!/bin/bash 
#author:lucaszhang@techtrex.com
#date:2022.10.27

#cpulimit 占比
percentage=$(($(nproc) * 20))

#获取数据库信息
host=`cat /KiosoftApplications/WebApps/kiosk_laundry_portal/application/config/database.php |grep laundry|grep hostname |awk -F "'" '{print $6}'`
user=`cat /KiosoftApplications/WebApps/kiosk_laundry_portal/application/config/database.php |grep laundry|grep username |awk -F "'" '{print $6}'`
password=`cat /KiosoftApplications/WebApps/kiosk_laundry_portal/application/config/database.php |grep laundry|grep password |awk -F "'" '{print $6}'`
port=`cat /KiosoftApplications/WebApps/kiosk_laundry_portal/application/config/database.php |grep laundry|grep -w port |awk -F "'" '{print $6}'`

#stop nginx and reportserver services
systemctl stop nginx
cd /KiosoftApplications/ServerApps/TTI_ReportServer && docker-compose stop

#backup mysql
today=`date +%Y%m%d`
cd /back/mysql/
if [ ! -d bak-$today ] ;then
    mkdir bak-$today
    cd bak-$today
    mysqldump -h$host -P$port -u$user -p$password laundry > laundry.sql
    mysqldump -h$host -P$port -u$user -p$password laundry_portal > laundry_portal.sql
    mysqldump -h$host -P$port -u$user -p$password value_code > value_code.sql
    mysqldump -h$host -P$port -u$user -p$password web_lcms > web_lcms.sql
	echo "mysql dump over,you can cuntune;gzip will run in the background"
	ls -lh .
    pwd
    nohup cpulimit -l $percentage /usr/bin/gzip /back/mysql/bak-$today/* &
else
    echo "backup dir exists!!!"
fi
