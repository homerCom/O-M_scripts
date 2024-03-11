#!/bin/bash
#lucaszhang@techtrex.com
#20230116
#Install filebeat for Route customer

[ -d /usr/local/filebeat ]&&echo "filebeat exist"&&exit 1 
cd /usr/local/src
wget http://download.vaststar.net/filebeat.zip
unzip filebeat.zip
unzip filebeat-6.7.1-linux-x86_64.zip
mv /usr/local/src/filebeat-6.7.1-linux-x86_64 /usr/local/filebeat

servername=`hostname`
customername=`hostname|awk -F '-' '{print$1}'`
sed -i "s/testcustomer/$customername/g" /usr/local/filebeat/filebeat.yml
sed -i "s/testserver/$servername/g" /usr/local/filebeat/filebeat.yml
chmod +x /usr/local/filebeat/filebeat

mv /usr/local/src/filebeat.service /lib/systemd/system/
systemctl start filebeat
systemctl enable filebeat