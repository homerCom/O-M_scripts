#!/bin/bash

/usr/bin/docker ps >/dev/null 2>&1
if [ $? -eq 0 ];
then
	containerName=`docker ps -a|grep ftxjoy|awk '{print$1}'`
	if [[ ! -n $(docker ps | grep ftxjoy) ]];then
		echo "ftxjoy未启动"
		/usr/bin/docker start $containerName
		now=`date +"%Y-%m-%d %H:%M:%S"`
		echo "$now ftjoy容器未启动，启动ftxjoy容器" >>/var/log/docker.log
	else
		/usr/bin/docker exec -i ftxjoy /usr/bin/ping -c 2 -w 2 www.baidu.com > /dev/null 2>&1
		if [ $? -eq 0 ];
		then
			echo "ftxjoy容器运行正常"
		else
			/bin/systemctl restart docker.service
			now=`date +"%Y-%m-%d %H:%M:%S"`
			echo "$now ftxjoy连接外网失败，重启docker应用" >>/var/log/docker.log
		fi
	fi
else
	/bin/systemctl restart docker.service
	now=`date +"%Y-%m-%d %H:%M:%S"`
	echo "$now docker未启动，启动docker应用" >>/var/log/docker.log
fi
