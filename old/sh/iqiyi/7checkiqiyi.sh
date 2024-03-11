#!/bin/bash
xsVpn=`ifconfig | awk '/10\.8\./{print $2}'|awk -F ':' '{print $2}'`
echo "----hostname----"
hostname
echo
echo "----/etc/sysconfig/network----"
cat /etc/sysconfig/network
echo
echo "----/etc/hosts----"
cat /etc/hosts
echo
echo "----ip----"
ip a
echo
echo "电影拷贝情况："
df -h
echo
echo "本地d_config"
mysql -uxiaoshuai -ptravelink -e "use tlkcs;select * from d_config where id in (14,15,16,20,21) or name='hz_hotel_id';"
echo 
echo "小帅VPN"
echo $xsVpn
echo
echo "此酒店云端信息"
mysql -h 120.26.71.181 -uroot -ptravelink -e "use manage;select id,hotelName,hotel,ipaddr,hzid,banquan,clientNo,clientNoPc,clientNoTv from h_hotels where ipaddr like \"%$xsVpn%\""
