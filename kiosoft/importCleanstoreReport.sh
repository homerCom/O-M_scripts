#!/bin/bash
#2023-03-27
#lucaszhang@techtrex.com

host="prod-retail-kiosoft.mariadb.database.azure.com"
user="retail-web@prod-retail-kiosoft"
passwd="123456"
cpuLimit="cpulimit -l 40"

if [ ! -d "/tmp/report" ];then
    mkdir /tmp/report
fi

#u04
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_laundry.u04 where id < 1000000" > /tmp/report/u04-01.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_laundry.u04 where id >= 1000000 and id < 2000000 " > /tmp/report/u04-02.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_laundry.u04 where id >= 2000000 " > /tmp/report/u04-03.xls
#n01
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_laundry.n01" > /tmp/report/n01.xls
#r04
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_laundry.r04" > /tmp/report/r04.xls
#account_refill_log
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_value_code.account_refill_log" > /tmp/report/account_refill_log.xls

#pack
cd /tmp/report
today=`/usr/bin/date '+%Y%m%d'`
$cpuLimit zip -r cleanstore_report_$today.zip *
mv /tmp/report/cleanstore_report_$today.zip /disk59-prod-backup/kiosoft/cleanstore/report/
rm -rf /tmp/report/*.xls
