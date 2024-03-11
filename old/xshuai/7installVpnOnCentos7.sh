#!/bin/bash
# vpn的tar包格式：tar包下直接是所有vpn相关文件
# 格式：脚本名 VPNCode

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 1 ]&&echo "参数不正确"&&exit 1
vpncode=$1
wget http://120.26.231.165:8080/securehotel/client_xs$vpncode.tar.gz

tar -xzvf client_xs$vpncode.tar.gz -C /etc/openvpn/
openvpn --daemon --cd /etc/openvpn --config client_xsnew.conf
echo "openvpn --daemon --cd /etc/openvpn --config client_xsnew.conf" >> /etc/rc.local
sleep 6
echo
ifconfig
rm client_xs$vpncode.tar.gz $0
