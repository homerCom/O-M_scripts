#!/bin/bash
# lucaszhang@techtrex.com
# 20231221
# update node

if [ -d /usr/local/node ];then
    today=`date +%Y%m%d`
	systemctl stop node
	/usr/local/node/bin/pm2 stop all
	mv /usr/local/node /usr/local/node-$today
	mv /etc/init.d/node /etc/init.d/node-$today

	wget -P /usr/local/src/ https://nodejs.org/dist/v16.20.2/node-v16.20.2-linux-x64.tar.gz
	cd /usr/local/src/
	tar -zxvf node-v16.20.2-linux-x64.tar.gz
	mv node-v16.20.2-linux-x64 /usr/local/node
	/usr/local/node/bin/npm install pm2 -g
	/usr/local/bin/npm  install forever -g
	
	echo "[Unit]
	Description=Forever for Node.js
	After=network.target
	
	[Service]
	Type=forking
	ExecStart=/usr/local/node/bin/forever start -l /tmp/node.log --pidFile /tmp/node.pid -a /KiosoftApplications/WebApps/kiosk_web_lcms/lcms-bridge/app.js
	Restart=always
	User=ccmbridge
	
	[Install]
	WantedBy=multi-user.target" >> /etc/systemd/system/node.service
	
	systemctl daemon-reload
	systemctl start node
	systemctl enable node
	
	cd /KiosoftApplications/WebApps/kiosk_laundry_portal/msg-proxy/
    pm2 start serve.js  --name node_msg
	pm2 startup
    systemctl enable pm2-root

fi