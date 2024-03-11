#!/bin/bash

nginx_conf="/usr/local/nginx/conf/nginx.conf"
conf_dir="/usr/local/nginx/conf/conf.d"
today=`date +%Y-%m-%d`

log_format="   log_format elk_json escape=json  '{\"domain\":\"\$server_name\", \"real_ip\":\"\$remote_addr\", \"http_x_forwarded_for\":\"\$http_x_real_ip\", \"time_local\":\"\$time_iso8601\", \"request\":\"\$request\", \"request_body\":\"\$request_body\", \"http_status\":\$status, \"body_bytes_sent\":\$body_bytes_sent, \"http_referer\":\"\$http_referer\", \"upstream_response_time\":\$upstream_response_time, \"request_time\":\$request_time, \"http_user_agent\":\"\$http_user_agent\", \"upstream_addr\":\"\$upstream_addr\", \"upstream_status\":\$upstream_status}';"

# add phpfpm_status
if [ ! -f /usr/local/nginx/conf/conf.d/php.conf ];then
   wget -P /usr/local/nginx/conf/conf.d/ https://download.vaststar.net/php.conf --no-check-certificate 
   echo "pm.status_path = /phpfpm_status" | sudo tee -a /usr/local/php/etc/php-fpm.d/www.conf
   if [ $? -eq 0 ]; then
        systemctl restart php-fpm
        /usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
        if [ $? -eq 0 ];then
            systemctl restart nginx
            echo "phpfmp_status added successfully."
        else
            echo "nginx config file error!"
        fi
   fi
else
   echo "Nothing done, /usr/local/nginx/conf/conf.d/php.conf exists."
fi

# modify nginx log format
if grep -q "request_body" "$nginx_conf"; then
    echo "Log format 'elk_json' already exists in $nginx_conf. Exiting."
else
	mkdir /back/nginx-$today

	cp "$nginx_conf" /back/nginx-$today/
	cp -r $conf_dir /back/nginx-$today/

	sed -i "/ttiold/ i\ $log_format\n" "$nginx_conf"
	find "$conf_dir" -type f -exec sed -i 's/tti/elk_json/g' {} +

	if [ $? -eq 0 ]; then
		echo "Log format added successfully."
		/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
		if [ $? -eq 0 ];then
			systemctl restart nginx
		else
			echo "nginx config file error!"
		fi
	else
		echo "Error: Unable to add log format."
	fi
fi

