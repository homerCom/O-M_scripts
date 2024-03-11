#!/bin/bash
# 功能：执行完风霆迅的脚本后，安装小帅的vpn，外加iptables设置
# 格式：脚本名 VPNCode

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 1 ]&&echo "请输入vpncode"&&exit 1
vpncode=$1
wget http://219.146.255.198:8098/vpn/$vpncode.tar.gz
groupadd nogroup
tar -xzvf $vpncode.tar.gz -C /etc/openvpn/
sleep 2
service openvpn restart
sleep 10
ifconfig
   
#防火墙
echo 
echo "start iptables"
sleep 1
iptables -I INPUT -p tcp --dport 8000 -j ACCEPT
iptables -I INPUT -p tcp --dport 8098 -j ACCEPT
iptables -I INPUT -s 10.5.0.0/16 -p tcp -m tcp --dport 22 -j ACCEPT
service iptables save
printf "%-60s%s\n" "IPTABLES" "[OK]"
