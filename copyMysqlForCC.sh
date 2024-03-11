#!/bin/bash
#2023-08-21
#lucaszhang@techtrex.com
#Dump mysql database and mv to /KiosoftApplications/WebApps/kiosk_laundry_portal

cd /tmp/sql
cpulimit -l 50 /usr/local/mysql/bin/mysqldump -ukiosoft -p123456 laundry --tables n01 p01 modem cbbt_app_trans cbbt_coin_trans n02 u04 cash_coin_report r03 > laundry.sql
cpulimit -l 50 /usr/local/mysql/bin/mysqldump -ukiosoft -p123456 laundry_portal --tables users locations rooms machine_error_report > laundry_portal.sql
cpulimit -l 50 /usr/local/mysql/bin/mysqldump -ukiosoft -p123456 value_code --tables credit_refund_log account_refund_log get_valuecode account_refill_log > value_code.sql

cpulimit -l 50 zip -r AAdvantage.zip laundry.sql laundry_portal.sql value_code.sql
mv AAdvantage.zip /KiosoftApplications/WebApps/kiosk_laundry_portal/
rm -rf /tmp/sql/*.sql
