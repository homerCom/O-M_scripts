#!/usr/bin/python
# -*- coding:utf-8 -*-
#获取vpn信息，存入数据库

import subprocess
import pymysql

sub = subprocess.Popen("ls /var/www/share/10.8段key/ | grep -v makevpn.sh",stdout=subprocess.PIPE,shell=True)
res = sub.stdout.read().decode().strip().split()
for i in range(len(res)):
	vpn = '10.8.' + res[i].split('@')[0]
	name = res[i].split('@')[1]
	key = res[i].split('@')[2].split('.')[0][9:]
