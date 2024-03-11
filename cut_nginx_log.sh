#!/bin/bash
#author:lucaszhang@techtrex.com
#date:20220803
#function:cut all nginx log in /usr/local/nginx/logs

#variable
LOG_HOME=/usr/local/nginx/logs
yestime=$(date -d "yesterday" +%Y-%m-%d)
nginx_pid=/usr/local/nginx/logs/nginx.pid


#backup
for log in `ls /usr/local/nginx/logs |grep .log`
do
    mv $LOG_HOME/$log $LOG_HOME/oldversion/$log-$yestime.log
done

/bin/kill -USR1 `cat $nginx_pid`