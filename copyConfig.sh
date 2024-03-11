#!/bin/bash
# author:lucaszhang@techtrex.com
# date:2022.6.13

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1

dirname=`cat /usr/local/nginx/conf/conf.d/kiosoft_443.conf |grep server_name|awk '{print $2}'|awk -F ';' '{print$1}'`
webdir='/KiosoftApplications/WebApps'
serverdir='/KiosoftApplications/ServerApps'

#Create dir
mkdir -p /tmp/$dirname/kiosk_laundry_portal/application/config
mkdir -p /tmp/$dirname/kiosk_laundry_portal/application/logs/task_schedulers
mkdir -p /tmp/$dirname/kiosk_laundry_portal/msg-proxy/config
mkdir -p /tmp/$dirname/kiosk_value_code/application/config
mkdir -p /tmp/$dirname/kiosk_value_code/application/logs/schedule_tasks
mkdir -p /tmp/$dirname/kiosk_web_lcms/application/config
mkdir -p /tmp/$dirname/kiosk_web_lcms/lcms-bridge/etc
mkdir -p /tmp/$dirname/kiosk_web_rss/application/config
mkdir -p /tmp/$dirname/TTI_ReportServer
mkdir -p /tmp/$dirname/TTI_tcp

#Copy files
#different
if [ ! -d /KiosoftApplications/ServerApps/TTI_Proxy ];
#Route
then
	#Laundry_Portal
	cp -r $webdir/kiosk_laundry_portal/application/config/{config.php,database.php,email.php,oauth2.php,site_info.php} /tmp/$dirname/kiosk_laundry_portal/application/config/
	cp -r $webdir/kiosk_laundry_portal/application/logs/task_schedulers/{account_based_card_runner.php,daily_sut_runner.php,machine_error_runner.php,negative_balance_alert_runner.php,negative_balance_protection_runner.php,recurring_4g_runner.php,recurring_runner.php,room_error_runner.php,router_runner.php} /tmp/$dirname/kiosk_laundry_portal/application/logs/task_schedulers/
	cp -r $webdir/kiosk_laundry_portal/msg-proxy/config/{sms.js,smtp.js} /tmp/$dirname/kiosk_laundry_portal/msg-proxy/config/
	#Value_Code
	cp -r $webdir/kiosk_value_code/application/config/{config.php,database.php,site_info.php} /tmp/$dirname/kiosk_value_code/application/config/
	#CCM
	cp -r $webdir/kiosk_web_lcms/application/config/{config.php,database.php,email.php,socket.php,user_setting.php} /tmp/$dirname/kiosk_web_lcms/application/config/
	#RSS
	cp -r $webdir/kiosk_web_rss/application/config/{config.php,database.php,email.php,site_info.php} /tmp/$dirname/kiosk_web_rss/application/config/
#Retail
else
	#Laundry_Portal
	cp -r $webdir/kiosk_laundry_portal/application/config/{config.php,database.php,email.php,oauth2.php,redis.php,site_info.php} /tmp/$dirname/kiosk_laundry_portal/application/config/
	cp -r $webdir/kiosk_laundry_portal/application/logs/task_schedulers/{daily_sut_runner.php,import_order_to_es.php,recurring_4g_runner.php,recurring_ar_report.php,recurring_billing_charge.php,recurring_generate_billing.php,recurring_runner.php,remote_price_runner.php,room_error_runner.php,router_runner.php,sync_order_to_es.php} /tmp/$dirname/kiosk_laundry_portal/application/logs/task_schedulers/
	#Value_Code
	cp -r $webdir/kiosk_value_code/application/config/{config.php,database.php,site_info.php,redis.php} /tmp/$dirname/kiosk_value_code/application/config/
	#CCM
	cp -r $webdir/kiosk_web_lcms/application/config/{config.php,database.php,email.php,socket.php,user_setting.php,redis.php} /tmp/$dirname/kiosk_web_lcms/application/config/
	#RSS
	cp -r $webdir/kiosk_web_rss/application/config/{config.php,database.php,email.php,site_info.php,redis.php} /tmp/$dirname/kiosk_web_rss/application/config/
fi

#common
cp -r $webdir/kiosk_value_code/application/logs/schedule_tasks/update_credit_refund.php /tmp/$dirname/kiosk_value_code/application/logs/schedule_tasks/
cp -r $webdir/kiosk_laundry_portal/application/migrations /tmp/$dirname/kiosk_laundry_portal/application/
cp -r $webdir/kiosk_value_code/application/migrations /tmp/$dirname/kiosk_value_code/application/
cp -r $webdir/kiosk_web_lcms/application/migrations /tmp/$dirname/kiosk_web_lcms/application/
#CCM
cp -r $webdir/kiosk_web_lcms/lcms-bridge/etc/config.js /tmp/$dirname/kiosk_web_lcms/lcms-bridge/etc/
#ServerApps
cp -r $serverdir/TTI_ReportServer/{docker-compose.yaml,env} /tmp/$dirname/TTI_ReportServer/
cp -r $serverdir/TTI_tcp/{config.json,docker-compose.yaml,Dockerfile} /tmp/$dirname/TTI_tcp/

#tar
cd /tmp/$dirname/
zip -r /tmp/${dirname}.zip *
rm -rf /tmp/$dirname
