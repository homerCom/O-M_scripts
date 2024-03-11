#!/bin/sh
# -*- coding: utf-8 -*-
# Author: CIASM
# Date: 2022/07/11
 
groupadd --system prometheus
useradd -s /sbin/nologin --system -g prometheus prometheus
mkdir /etc/prometheus/
 
apt install python2 pip -y
pip install prometheus-pve-exporter
 
cat << EOF > /etc/prometheus/pve.yml
default:
  user: root@pam
  password: ZHMczq@0906
  verify_ssl: false
EOF
 
chown -R prometheus:prometheus /etc/prometheus/
chmod -R 775 /etc/prometheus/
 
cat << EOF > /etc/systemd/system/pve-exporter.service
[Unit]
Description=Prometheus exporter for Proxmox VE
Documentation=https://github.com/znerol/prometheus-pve-exporter
 
[Service]
Restart=always
User=prometheus
ExecStart=/usr/local/bin/pve_exporter /etc/prometheus/pve.yml
 
[Install]
WantedBy=multi-user.target
EOF
 
systemctl daemon-reload && systemctl enable --now pve-exporter && systemctl start pve-exporter
