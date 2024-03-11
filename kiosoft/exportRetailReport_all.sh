#!/bin/bash
#2023-05-15
#lincolnzhang@techtrex.com

cpuLimit="cpulimit -l 30"
host="prod-retail-kiosoft.mariadb.database.azure.com"
user="lincoln@prod-retail-kiosoft"
passwd="lincoln123"


if [ ! -d "/tmp/report" ];then
    mkdir /tmp/report
fi

#cleanstore_laundry_u04
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_laundry.u04 where id < 1000000" > /tmp/report/cleanstore-u04-01.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_laundry.u04 where id >= 1000000 and id < 2000000 " > /tmp/report/cleanstore-u04-02.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_laundry.u04 where id >= 2000000 and id < 3000000" > /tmp/report/cleanstore-u04-03.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_laundry.u04 where id >= 3000000 and id < 4000000" > /tmp/report/cleanstore-u04-04.xls
#n01
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_laundry.n01" > /tmp/report/cleanstore-n01.xls
#r04
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_laundry.r04" > /tmp/report/cleanstore-r04.xls
#account_refill_log
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from cleanstore_value_code.account_refill_log" > /tmp/report/cleanstore-account_refill_log.xls

#amusement_laundry
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from amusement_laundry.u04" > /tmp/report/amusement-u04.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from amusement_laundry.n01" > /tmp/report/amusement-n01.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from amusement_laundry.r04" > /tmp/report/amusement-r04.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from amusement_value_code.account_refill_log" > /tmp/report/amusement-account_refill_log.xls
#coffee_back_end
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from coffee_back_end.payment_information" > /tmp/report/coffee-payment_infomation.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from coffee_back_end.payment_log" > /tmp/report/coffee-payment_log.xls
#integration_laundry
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from integration_laundry.u04" > /tmp/report/intergration-u04.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from integration_laundry.u04 where id < 1000000" > /tmp/report/integration-u04-01.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from integration_laundry.u04 where id >= 1000000 and id < 2000000" > /tmp/report/integration-u04-02.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from integration_laundry.u04 where id >= 2000000 and id < 3000000" > /tmp/report/integration-u04-03.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from integration_laundry.n01" > /tmp/report/integration-n01.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from integration_laundry.r04" > /tmp/report/integration-r04.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from integration_value_code.account_refill_log" > /tmp/report/integration-account_refill_log.xls

#international_laundry
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from international_laundry.u04" > /tmp/report/international-u04.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from international_laundry.n01" > /tmp/report/international-n01.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from international_laundry.r04" > /tmp/report/international-r04.xls
$cpuLimit /usr/bin/mysql -h$host -u$user -p$passwd -e "select * from international_value_code.account_refill_log" > /tmp/report/international-account_refill_log.xls





#pack
cd /tmp/report
today=`/usr/bin/date '+%Y%m%d'`
$cpuLimit zip -r all_report_$today.zip *
mv /tmp/report/all_report_$today.zip /disk59-prod-backup/kiosoft/cleanstore/report/
rm -rf /tmp/report/*.xls
