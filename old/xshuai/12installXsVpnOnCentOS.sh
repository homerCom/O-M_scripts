#!/bin/bash
# 格式：脚本名 VPNCode

[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1
[ $# -ne 1 ]&&echo "请输入vpncode和风霆迅key"&&exit 1
vpncode=$1

# before install
wget http://219.146.255.198:8098/py/1getHotelName.py
ftxkey=`hostname`
python 1getHotelName.py $ftxkey
[ $? -eq 1 ]&&echo "Please fill in the hotelInfo on the cloud!"&&rm -rf 1getHotelName.py&&exit 1

# iptables
echo 
echo "start iptables"
sleep 1
iptables -I INPUT -p tcp --dport 8000 -j ACCEPT
iptables -I INPUT -p tcp --dport 8098 -j ACCEPT
iptables -I INPUT -s 10.8.0.0/26 -p tcp -m tcp --dport 22 -j ACCEPT
service iptables save

# 修改服务器密码
if cat /etc/issue | grep -q Ubuntu;then
        echo travelink:xshotel123 | chpasswd
else
        echo root:xshotel123 | chpasswd
fi

# vpn
wget http://120.26.231.165:8080/securehotel/client_xs$vpncode.tar.gz
groupadd nogroup
tar -xzvf client_xs$vpncode.tar.gz -C /etc/openvpn/
sleep 2
service openvpn restart
sleep 10
ifconfig

# 云端占位
echo
python 1getHotelName.py $ftxkey | tee temp.txt
echo
hotelname=`cat temp.txt | awk -F ':' '/remarks/{print $2}'` 
xsVpn=`ifconfig | awk '/10\.8\./{print $2}'|awk -F ':' '{print $2}'`
curl -s "http://120.26.71.181/manage/port/addNewHotel?vpn=$xsVpn:8000&hotelname=$hotelname&key=$ftxkey"
echo
rm -rfv *
echo
echo "1.前往云端添加设备数量！"
echo "2.前往252的/var/www/share/10.8段key/里记录酒店信息！"
echo "3.前往公司服务器打包后台，准备部署"
echo
