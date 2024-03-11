#!/bin/bash
#2023-06-18
#lincolnzhang@techtrex.com
cpuLimit="cpulimit -l 30"
Prod_host="prod-retail-kiosoft.mariadb.database.azure.com"
Prod_user="report@prod-retail-kiosoft"
Prod_passwd="b&#2@BVT"


#数据库文件暂存目录
cd /opt/tempData/

#导出测试数据库
$cpuLimit /usr/bin/mysqldump -u$Prod_user -p$Prod_passwd -h$Prod_host cleanstore_laundry > cleanstore_laundry.sql
$cpuLimit /usr/bin/mysqldump -u$Prod_user -p$Prod_passwd -h$Prod_host cleanstore_value_code > cleanstore_value_code.sql

$cpuLimit /usr/bin/mysqldump -u$Prod_user -p$Prod_passwd -h$Prod_host integration_laundry > integration_laundry.sql
$cpuLimit /usr/bin/mysqldump -u$Prod_user -p$Prod_passwd -h$Prod_host integration_value_code > integration_value_code.sql

$cpuLimit /usr/bin/mysqldump -u$Prod_user -p$Prod_passwd -h$Prod_host amusement_laundry > amusement_laundry.sql
$cpuLimit /usr/bin/mysqldump -u$Prod_user -p$Prod_passwd -h$Prod_host amusement_value_code > amusement_value_code.sql

$cpuLimit /usr/bin/mysqldump -u$Prod_user -p$Prod_passwd -h$Prod_host international_laundry > international_laundry.sql
$cpuLimit /usr/bin/mysqldump -u$Prod_user -p$Prod_passwd -h$Prod_host international_value_code > international_value_code.sql
#导入测试数据库
/usr/bin/mysql -ureport@azure-retailstage -p123456 -h azure-retailstage.mariadb.database.azure.com -Dcheck_cleanstore_laundry --default-character-set=utf8 < cleanstore_laundry.sql
/usr/bin/mysql -ureport@azure-retailstage -p123456 -h azure-retailstage.mariadb.database.azure.com -Dcheck_cleanstore_value_code --default-character-set=utf8 < cleanstore_value_code.sql

/usr/bin/mysql -ureport@azure-retailstage -p123456 -h azure-retailstage.mariadb.database.azure.com -Dcheck_integration_laundry --default-character-set=utf8 < integration_laundry.sql
/usr/bin/mysql -ureport@azure-retailstage -p123456 -h azure-retailstage.mariadb.database.azure.com -Dcheck_integration_value_code --default-character-set=utf8 < integration_value_code.sql

/usr/bin/mysql -ureport@azure-retailstage -p123456 -h azure-retailstage.mariadb.database.azure.com -Dcheck_amusement_laundry --default-character-set=utf8 < amusement_laundry.sql
/usr/bin/mysql -ureport@azure-retailstage -p123456 -h azure-retailstage.mariadb.database.azure.com -Dcheck_amusement_value_code --default-character-set=utf8 < amusement_value_code.sql

/usr/bin/mysql -ureport@azure-retailstage -p123456 -h azure-retailstage.mariadb.database.azure.com -Dcheck_international_laundry --default-character-set=utf8 < international_laundry.sql
/usr/bin/mysql -ureport@azure-retailstage -p123456 -h azure-retailstage.mariadb.database.azure.com -Dcheck_international_value_code --default-character-set=utf8 < international_value_code.sql

rm -rf *.sql

cd /opt/RetailData
sh RetailData > log.txt

mv RetailData_*.xlsx /disk60-prod-backup-data/kiosoft/cleanstore/report/

