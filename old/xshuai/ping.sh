#!/bin/bash
#功能：扫描某一网段内正在使用的IP地址
#用法：脚本名
#author：Homer

read -e -p "enter the start IP：" start
read -e -p "enter the last IP：" last

ip1=`echo $start|awk -F '.' '{print $4}'`
ip2=`echo $last|awk -F '.' '{print $4}'`
net1=`echo $start|awk -F '.' '{print $3}'`
net2=`echo $last|awk -F '.' '{print $3}'`
if [ $net1 -ne $net2 ];then
	echo "起始IP和终止IP不在同一网段，请检查!"&&exit 1
fi
if [ $ip1 -gt $ip2 ];then
	echo "起始IP大于终止IP，请检查!"&&exit 1
fi
netaddr=`echo $start|awk -F '.' '{print $1"."$2"."$3"."}'`
echo "起始IP："$netaddr$ip1
echo "终止IP："$netaddr$ip2

for((i=$ip1;i<=$ip2;i++));
do
	ping $netaddr$i -c 1 -i 0.5  >/dev/null
	if [ $? -ne 0 ];then 
                echo $netaddr$i "Died"
        else
                echo $netaddr$i "Alive"
                echo $netaddr$i >> $PWD/alive.txt
  	     fi
done

