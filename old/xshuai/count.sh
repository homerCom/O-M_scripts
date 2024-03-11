#!/bin/bash
#功能：服务器断开外网时间统计
#用法：设置定时任务为每分钟执行一次
#author ：Homer

if [ ! -f /root/temp/flag.txt ];then
	echo 0 > /root/temp/flag.txt
fi
n=`cat /root/temp/flag.txt`
ping 219.146.255.198 -c 2 > /dev/null
if [ $? -ne 0 ];then
	n=$[$n+1]
	echo $n > /root/temp/flag.txt
else
	echo 0 > /root/temp/flag.txt
fi
if [ `cat /root/temp/flag.txt` -ge 6 ];then
	echo "断网超过5分钟，请检查服务器网络！"
fi
