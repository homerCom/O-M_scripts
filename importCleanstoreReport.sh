#!/bin/bash
#2023-03-06
#lucaszhang@techtrex.com

mkdir /tmp/report
#u04
/usr/local/mysql/bin/mysql -hprod-retail-kiosoft.mariadb.database.azure.com -ukiosoft@prod-retail-kiosoft -p123456 -e "select * from laundry.u04 where id < 1000000" > /tmp/report/u04-01.xls
/usr/local/mysql/bin/mysql -hprod-retail-kiosoft.mariadb.database.azure.com -ukiosoft@prod-retail-kiosoft -p123456 -e "select * from laundry.u04 where id >= 1000000 and id < 2000000 " > /tmp/report/u04-02.xls
/usr/local/mysql/bin/mysql -hprod-retail-kiosoft.mariadb.database.azure.com -ukiosoft@prod-retail-kiosoft -p123456 -e "select * from laundry.u04 where id >= 2000000 " > /tmp/report/u04-03.xls
#n01
/usr/local/mysql/bin/mysql -hprod-retail-kiosoft.mariadb.database.azure.com -ukiosoft@prod-retail-kiosoft -p123456 -e "select * from laundry.n01" > /tmp/report/n01.xls
#r04
/usr/local/mysql/bin/mysql -hprod-retail-kiosoft.mariadb.database.azure.com -ukiosoft@prod-retail-kiosoft -p123456 -e "select * from laundry.r04" > /tmp/report/r04.xls
#account_refill_log
/usr/local/mysql/bin/mysql -hprod-retail-kiosoft.mariadb.database.azure.com -ukiosoft@prod-retail-kiosoft -p123456 -e "select * from value_code.account_refill_log" > /tmp/report/account_refill_log.xls

#pack
cd /tmp/report
today=`date -d tomorrow +'%Y%m%d'`
cpulimit -l 50 zip -r cleanstore_report_$today.zip *
rm -rf /tmp/report/*.xls
mv /tmp/report/cleanstore_report_$today.zip /KiosoftApplications/WebApps/kiosk_laundry_portal/