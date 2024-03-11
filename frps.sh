#!/bin/bash

# 安装frps
cd /usr/local
#wget https://github.com/fatedier/frp/releases/download/v0.48.0/frp_0.48.0_linux_amd64.tar.gz
wget http://download.vaststar.net/frp_0.48.0_linux_amd64.tar.gz
tar -xzf frp_0.48.0_linux_amd64.tar.gz
mv frp_0.48.0_linux_amd64 frp

# 创建frps服务文件
cat <<EOF > /etc/systemd/system/frps.service
[Unit]
Description=Frp Server Service
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=5s
ExecStart=/usr/local/frp/frps -c /usr/local/frp/frps.ini

[Install]
WantedBy=multi-user.target
EOF

# 创建frps配置文件
cat <<EOF > /usr/local/frp/frps.ini
[common]
bind_addr = 0.0.0.0
bind_port = 9443
dashboard_port = 9444
vhost_http_port = 8000
vhost_https_port = 8443
dashboard_user= admin
dashboard_pwd= admin
token = token@admin
EOF

# 设置服务开机自启动
systemctl enable frps.service

# 启动服务
systemctl start frps.service

echo "frps安装完成并已启动！"

pubip=`curl -s https://api.ipify.org`
echo "[common]
server_addr = $pubip  #你的云服务器公网IP地址
server_port = 7000    #服务器服务端口，需要在云服务防火墙放行
token = token@admin   #客户端连接服务器的密码，需要和服务器一致

[windows_remote_desk]
type = tcp
local_ip = 127.0.0.1  #本机地址，也可填写本机内网IP地址
local_port = 3389     #本机要穿透出去的端口，比如windows远程桌面的端口3389
remote_port = 13389   #穿透到公网之后的端口号，自定义，需要在云服务器安全组允许进入

[linux_ssh]
type = tcp
local_ip = 127.0.0.1  #本机地址，也可填写本机内网IP地址
local_port = 22       #本机要穿透出去的端口，比如linux默认ssh端口22
remote_port = 2222    #穿透到公网之后的端口号，自定义，需要在云服务器安全组允许进入