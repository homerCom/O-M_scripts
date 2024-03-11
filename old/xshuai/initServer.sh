#!/bin/bash
#初始化服务器

#1.添加堡垒机
useradd -m xsops
echo xsops:xsops123 | chpasswd
useradd -m iqiyi
echo iqiyi:iqiyi123 | chpasswd
/usr/local/xiaoshuai/sh/2addtojms.py

#2.网卡自动获取
for eth in `ip a|grep BROADCAST |grep -v docker |awk '{print$2}'|awk -F ':' '{print$1}'`
do
	echo "DEVICE=$eth
BOOTPROTO=dhcp
ONBOOT=yes"> /etc/sysconfig/network-scripts/ifcfg-$eth
done
systemctl restart network.service
