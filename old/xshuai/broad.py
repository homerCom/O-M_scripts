#!/usr/bin/python
#-*- coding:utf-8 -*-

import socket
import time
import json

udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
dest = ("<broadcast>",4396)
info = {"ip":"127.0.0.1","port":"","server":"hclient"}


def get_host_ip(): 
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    finally:
        s.close()
    return ip

while True:
	server_ip = get_host_ip()
	info['ip'] = server_ip
	json_info = json.dumps(info)
	udp.sendto(json_info.encode('utf-8'),dest)
	time.sleep(1)
