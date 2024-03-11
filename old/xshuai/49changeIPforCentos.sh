#!/bin/bash
#修改centos6,7系统的IP地址

netcard=`ip a | grep -v "169\.254" | awk '/inet.*brd/{print $NF}' | sort | uniq`
version=`cat /etc/redhat-release|awk '{print $(NF-1)}'|awk -F '.' '{print $1}'`

while true
do
read -e -p '
[1] 设置静态IP      Set static ip
[2] 设置动态IP      Set to DHCP
[3] 测试网络状态    Testing Network
[0] 退出            Exit

请选择 Please choose 0 1 2 3 :' choice

if [ $choice -eq 1 ]
then
	read -e -p "Please input the IP:" IPADDR
	read -e -p "Please input the netmask:" NETMASK
	read -e -p "Please input the gateway:" GATEWAY

	if [ $version -eq 7 ];then
        	echo -e "BOOTPROTO=static\nDEVICE=$netcard\nONBOOT=yes\nIPADDR=$IPADDR\nNETMASK=$NETMASK\nGATEWAY=$GATEWAY\nDNS1=114.114.114.114\nDNS2=8.8.8.8" > /etc/sysconfig/network-scripts/ifcfg-$netcard
        	systemctl restart network
	elif [ $version -eq 6 ];then
        	hwaddr=`cat /etc/sysconfig/network-scripts/ifcfg-$netcard | grep 'HWADDR'|cut -f 2 -d '='`
        	echo -e "BOOTPROTO=static\nDEVICE=$netcard\nONBOOT=yes\nHWADDR=$hwaddr\nIPADDR=$IPADDR\nNETMASK=$NETMASK\nGATEWAY=$GATEWAY\nDNS1=114.114.114.114\nDNS2=8.8.8.8" > /etc/sysconfig/network-scripts/ifcfg-$netcard
        	service network restart
	fi

elif [ $choice -eq 2 ]
then
	if [ $version -eq 7 ];then
        	echo -e "BOOTPROTO=dhcp\nDEVICE=$netcard\nONBOOT=yes" > /etc/sysconfig/network-scripts/ifcfg-$netcard
        	systemctl restart network
	elif [ $version -eq 6 ];then
        	hwaddr=`cat /etc/udev/rules.d/70-persistent-net.rules|grep $netcard|awk -F ',' '{print $4}'|awk -F '"' '{print $2}'`
        	echo -e "BOOTPROTO=dhcp\nDEVICE=$netcard\nONBOOT=yes\nHWADDR=$hwaddr" > /etc/sysconfig/network-scripts/ifcfg-$netcard
        	service network restart
	fi

elif [ $choice -eq 3 ]
then 
	flag=1
	netmask=`ip route|grep "default via"|awk '{print $3}'`
	ping $netmask -c 3 > /dev/null
	if [ $? -ne 0 ]
	then
	        echo "Connecting to Gateway failed!"
       		flag = 0
	else
        	echo "Connecting to Gateway success!"
	fi

	ping www.baidu.com -c 3 > /dev/null
	if [ $? -ne 0 ]
	then
	        echo "Connecting to Public network failed!"
	        flag = 0
	else
        	echo "Connecting to Public network success!"
	fi

	if [ $flag -eq 1 ]
	then
       		printf "%-40s%s\n" "Network" "[OK]"
	else
        	echo "Network fault!"
	fi
elif [ $choice -eq 0 ]
then
	exit
else
	echo "输入有误，请输入正确的编号！"
fi
sleep 3
done
