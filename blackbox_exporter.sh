#!/bin/bash
#2023-03-03
#lucaszhang@techtrex.com

[ $UID -ne 0 ]&&echo "Please switch to root to execute this script"&&exit 1

wget http://download.vaststar.net/blackbox_exporter.zip -P /usr/local/src/
unzip /usr/local/src/blackbox_exporter.zip -d /usr/local/

mv /usr/local/blackbox_exporter/blackbox_exporter.service /etc/systemd/system/
systemctl enable blackbox_exporter

