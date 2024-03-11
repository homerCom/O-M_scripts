#!/bin/bash
NAME=aria2c
flag=`ps -ef |grep -w $NAME|grep -v grep|wc -l`
if [ $flag == 0 ];then
	/usr/bin/aria2c --conf-path=/etc/aria2c.conf -D
else
	echo "aria2c is running ....."
fi

