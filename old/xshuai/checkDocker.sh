#!/bin/bash
NAME=docker
for ((i=0;i<60;i++));
do
	flag=`ps -ef |grep -w $NAME|grep -v grep|wc -l`
	if [ $flag == 0 ];then
		systemctl restart docker.service
	else
		echo "Docker is running ....."
	fi
	sleep $i
done
