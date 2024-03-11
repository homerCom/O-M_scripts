#!/bin/bash

yum install docker -y && systemctl start docker.service && systemctl enable docker.service
curl ifconfig.me > /tmp/ip.txt
ip=`cat /tmp/ip.txt`
if [ -f Ftxjoy_hotel_docker_1.4.1.2_2020030301.zip ];then
	rm -rf Ftxjoy_hotel_docker_1.4.1.2_2020030301.zip
fi
if [ $ip == "219.146.255.198" ];
then
	wget http://192.168.1.252:8000/share/ftx/Ftxjoy_hotel_docker_1.4.1.2_2020030301.zip
else
	wget http://219.146.255.198:8098/share/ftx/Ftxjoy_hotel_docker_1.4.1.2_2020030301.zip
fi
unzip Ftxjoy_hotel_docker_1.4.1.2_2020030301.zip
docker load -i Ftxjoy_hotel_docker_1.4.1.2_2020030301.tar
docker run -itd --name ftxjoy --privileged -p 80:80 -p 8080:8080 -v /video:/video --restart always docker.ftxjoy.com/ftxjoy_hotel:1.4.1.2  /usr/sbin/init
wget -P /root/ http://219.146.255.198:8098/share/zhang/scripts/updateDockerTo1421.sh
rm -rf Ftxjoy_hotel_docker_1.4.1.2_2020030301.*
systemctl disable docker.service
