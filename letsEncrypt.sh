#!/bin/bash
#date：20220328
#author：lucaszhang@techtrex.com
#variable: domain (eg: bash letsEncrypt.sh baidu.com)


[ $UID -ne 0 ]&&echo "Please switch to root to execute this script"&&exit 1
[ $# -ne 1 ]&&echo "Please add parameter of domain name (for example: bash $0 baidu.com)"&&exit 1
domain=$1
flag=$(echo $domain | gawk '/^(http(s)?:\/\/)?[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+(:[0-9]{1,5})?$/{print $0}')
[ ! -n "${flag}" ]&&echo "Please enter the correct domain name"&&exit 1

mail="kaydenzhou@techtrex.com"

#install certbot
if [ ! -f /usr/bin/certbot ];
then
	yum install -y epel-release
	yum install -y snapd
	systemctl start snapd
	systemctl enable --now snapd.socket
	ln -s /var/lib/snapd/snap /snap
	snap install core; snap refresh core
	yum remove -y certbot
	snap install --classic certbot
	snap set certbot trust-plugin-with-root=ok
	snap install certbot-dns-cloudflare
	ln -s /snap/bin/certbot /usr/bin/certbot
else
    echo "/usr/bin/certbot exists"
fi

#Apply certificate and deploy
if [ ! -f /etc/letsencrypt/live/$domain/fullchain.pem ];then
	/usr/bin/certbot --nginx --nginx-server-root /usr/local/nginx/conf --nginx-ctl /usr/local/nginx/sbin/nginx -m $mail --agree-tos -n --domains $domain
	
	cert="\t\tssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;"
	key="\t\tssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;"

	for i in {443,5009,5010,5011}
	do
		if [ `grep -c "$domain" /usr/local/nginx/conf/conf.d/kiosoft_$i.conf` -ne '0' ];then
			sed -i "s!.*ssl_certificate .*!$cert!g" /usr/local/nginx/conf/conf.d/kiosoft_$i.conf
			sed -i "s!.*ssl_certificate_key.*!$key!g" /usr/local/nginx/conf/conf.d/kiosoft_$i.conf
		else
			echo "$domain is not in /usr/local/nginx/conf/conf.d/kiosoft_$i.conf"
		fi
	done

	/usr/local/nginx/sbin/nginx -s reload
else
	echo "/etc/letsencrypt/live/$domain/fullchain.pem exists."
fi

#crontab
cron=`crontab -l |grep "/usr/bin/certbot" | wc -l`
if [ "$cron" -eq 0 ];
then
    echo -e >> /var/spool/cron/root
    echo "## DO NOT REMOVE - THIS IS WHAT RENEWS AND KEEPS THE CERTIFICATE FOR SSL VALID ON THIS SERVER IF CERTBOT IS USED" >> /var/spool/cron/root
    echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/bin/certbot renew -q" >> /var/spool/cron/root
else
    echo "Cron for cert exists"
fi

###update php ssl
now=`date +"%Y%m%d%H%m%S"`
cp /usr/local/php/etc/ssl/curl-ca-bundle.crt /usr/local/php/etc/ssl/curl-ca-bundle.crt.bak-$now
wget -O  /usr/local/php/etc/ssl/curl-ca-bundle.crt http://curl.haxx.se/ca/cacert.pem  --no-check-certificate
systemctl restart php-fpm

rm $0
