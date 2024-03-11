#create dir
if [ ! -d "/back/rsync/logs/laundry_portal" ] ;then
    mkdir -p /back/rsync/{code,database,logs}
    mkdir -p /back/rsync/logs/{laundry_portal,value_code,reportServer,tokenServer,policyServer,tcp}
fi

#1.code
/usr/bin/rsync -avzrtopg /KiosoftApplications/WebApps/kiosk_laundry_portal /back/rsync/code/ --exclude={'*.gz','*.zip','*.log'}
/usr/bin/rsync -avzrtopg /KiosoftApplications/WebApps/kiosk_value_code /back/rsync/code/ --exclude={'*.gz','*.zip','*.log'}
/usr/bin/rsync -avzrtopg /KiosoftApplications/WebApps/kiosk_web_lcms /back/rsync/code/ --exclude={'*.gz','*.zip','*.log'}
/usr/bin/rsync -avzrtopg /KiosoftApplications/WebApps/kiosk_web_rss /back/rsync/code/ --exclude={'*.gz','*.zip','*.log'}


#2.log
#清空目录，不然会有重复压缩问题
rm -rf /back/rsync/logs/laundry_portal/*
rm -rf /back/rsync/logs/value_code/*
rm -rf /back/rsync/logs/reportServer/*
rm -rf /back/rsync/logs/tokenServer/*
rm -rf /back/rsync/logs/policyServer/*
rm -rf /back/rsync/logs/tcp/*

/usr/bin/rsync -avzrtopg `find /KiosoftApplications/WebApps/kiosk_laundry_portal/application/logs/ -name "*.log" -mtime +0` /back/rsync/logs/laundry_portal/
/usr/bin/rsync -avzrtopg `find /KiosoftApplications/WebApps/kiosk_value_code/application/logs/ -name "*.log" -mtime +0` /back/rsync/logs/value_code/
/usr/bin/rsync -avzrtopg `find /KiosoftApplications/ServerApps/TTI_ReportServer/logs -name "*.log.*" -mtime +0` /back/rsync/logs/reportServer/
/usr/bin/rsync -avzrtopg `find /tmp/TokenServerLog/* -mtime +0` /back/rsync/logs/tokenServer/
/usr/bin/rsync -avzrtopg `find /var/www/policyServerLog/* -mtime +0` /back/rsync/logs/policyServer/

line=`ls /KiosoftApplications/ServerApps/ |grep tcp|wc -l`
dir=`ls /KiosoftApplications/ServerApps/ |grep tcp`
if [ $line -eq "1" ] ;then
    /usr/bin/rsync -avzrtopg `find /KiosoftApplications/ServerApps/$dir/logs/ -name "*.log.*" -mtime +0` /back/rsync/logs/tcp/
fi

#gzip logs
find /back/rsync/logs/ -type f -exec gzip --rsyncable {} \;


#3.database
today=`/usr/bin/date +%w`
if [ $today -eq "3" ] ;then
    find /back/mysql/dir/ -mtime 1 -exec mv {} /back/rsync/database/ \;
elif [ $today -eq "4" ] ;then
    mv /back/rsync/database/*.gz /back/mysql/dir/
fi