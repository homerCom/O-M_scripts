#!/bin/bash
# 平台：centOS7
# 功能：网络 + lvm + vpn

#nicname=`ip ntable | grep dev | sort | uniq | sed -e 's/^.*dev //;/^lo/d'`
nicname=`ip a | grep -v "169\.254" | awk '/inet.*brd/{print $NF}' | sort | uniq`
while true
do
        read -e -p "Please enter the IP address: " IPADDR
        read -e -p "Please enter a subnet mask: " NETMASK
        read -e -p "Please enter a gateway: " GATEWAY
        echo
        echo "*********************************"
        echo "address:"$IPADDR
        echo "netmask:"$NETMASK
        echo "gateway:"$GATEWAY
        echo "*********************************"
        echo 
        while true
        do
            read -p "Press 0 to confirm,Press 1 to re-enter: " yn
            case $yn in
                0)
                sed -i '/ONBOOT/cONBOOT=yes' /etc/sysconfig/network-scripts/ifcfg-$nicname
                sed -i '/BOOTPROTO/cBOOTPROTO=static' /etc/sysconfig/network-scripts/ifcfg-$nicname
                sed -i '/IPADDR/,$d' /etc/sysconfig/network-scripts/ifcfg-$nicname
                echo -e "IPADDR=$IPADDR\nNETMASK=$NETMASK\nGATEWAY=$GATEWAY\nDNS1=114.114.114.114\nDNS2=8.8.8.8" >> /etc/sysconfig/network-scripts/ifcfg-$nicname
                sleep 1
                systemctl restart network
               	echo "sleep 20s...have a rest."
		for i in `seq 20`
		do
			sleep 1
			echo -n ". "
		done
		echo
                break 2
                ;;
                1)
                continue 2
                ;;
                * )
                echo "您的输入有误，请重新输入"
                continue
                ;;
            esac
        done
done

# password
echo root:xshotel123 | chpasswd

# broadcast
if [ -f /var/www/serverConfig/startBroad.php ];then
	kill `cat /var/www/serverConfig/process.txt`
	sleep 1
	/usr/bin/curl http://127.0.0.1/serverConfig/startBroad.php
fi

echo "Checking the network..."
ping www.163.com -c 4 2>/dev/null
[ $? -ne 0 ]&&echo "Can't Ping To www.163.com,Check The Network Configuration Please"&&exit 1
printf "%-60s%s\n" "Network" "[OK]"
pkill dhclient

## lvm
if [[ `df -h |grep cl-home` ]] ; then
	umount /home
	lvrename /dev/cl/home /dev/cl/video
	mkdir /video
	sed -i 's/home/video/g' /etc/fstab
	mount -a
	echo "lvm disk cl-home change to cl-video ok!"
else
	echo "lvm disk no cl-home!"
fi

## iptables
systemctl stop firewalld.service
systemctl disable firewalld
## selinux
sed -i /SELINUX=enforcing/s/enforcing/disabled/g /etc/selinux/config

## openvpn
if [ ! -f /etc/openvpn/client_xsnew.conf ];then
	while true
	do
		echo
		read -e -p "Please enter the key: " key
		echo
		if [ `curl -sI http://219.146.255.198:8098/vpns/vpn_$key.tar.gz | sed -n 1p | awk '{print $2}'` -ne 200 ];then
			echo "vpn_key error! re-input it again"
			continue
		else 
			break
		fi
	done
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
	yum install -y openvpn  
	wget http://219.146.255.198:8098/vpns/vpn_$key.tar.gz
	groupadd nogroup
	tar -xzvf vpn_$key.tar.gz -C /etc/openvpn/
	systemctl start openvpn@client_xsnew.service
	systemctl enable openvpn@client_xsnew.service
fi
sleep 5
ip a
echo
if [ ! -f /tmp/install/46startnet.sh ];then
	mkdir /tmp/install
	mv * /tmp/install
	wget http://219.146.255.198:8098/sh/47installXsOnCentOS7.sh -O /tmp/install/47installXsOnCentOS7.sh
	chmod 777 /tmp/install/*.sh
fi

while true
do
	read -e -p "Reboot now(Y) OR not(N): " yn
	case $yn in
		y)
		init 6
		;;
		n)
		break
		;;
		*)
		echo "input error!"
		continue
		;;
	esac
done
