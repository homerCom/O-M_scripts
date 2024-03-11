#!/bin/bash
# 功能：更换为163源，并安装openvpn
#       条件：通外网
# 格式：脚本名
mv /etc/apt/sources.list /etc/apt/sources.list.bak
wget -P /etc/apt http://219.146.255.198:8098/share/zhang/scripts/sources.list
apt-get update
apt-get install openvpn -y
