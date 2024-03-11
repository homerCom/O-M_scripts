#!/bin/bash
# 20231225
# lucaszhang@techtrex.com

blacklist_file="/usr/local/nginx_waf/conf/blacklist.conf"
ipfile="/tmp/ip.txt"

function log()
{
    log="$(date '+%Y-%m-%d %H:%M:%S') $@"
    echo $log >> /var/log/blacklist.log
}

cat /usr/local/nginx_waf/logs/waf_443.access.log |grep `date -d "1 minutes ago" +"%Y-%m-%d"T"%H:%M"`|awk -F '"' '{print$8}'|sort|uniq -c|sort -rn > $ipfile
sed -i 's/^[[:space:]]*//;s/[[:space:]]*$//' $ipfile

while read -r count ip; do
    if [ "$count" -gt 500 ]; then
        echo "deny $ip;" >> "$blacklist_file"
        log "$ip accesses $count times in 1 minute, is added to nginx_waf blacklist."
        /usr/local/nginx_waf/sbin/nginx -s reload -c /usr/local/nginx_waf/conf/nginx.conf
    fi
done < $ipfile