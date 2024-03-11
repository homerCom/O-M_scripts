#!/usr/bin/python
# -*- coding:UTF-8 -*-
#注释：获取服务器信息

import subprocess

def get_disk():
	with open("/etc/redhat-release",'r') as f:
		#print(f.read().replace("\n",''))
		sys_num = f.read().replace("\n",'')
		f.close()
	if '6.6' in sys_num:
		sub = subprocess.Popen("df -lh|grep -w /|awk '{print $4}'&&df -lh|grep -w /video|awk '{print $4}'",stdout=subprocess.PIPE,shell=True)
		res = sub.stdout.read().decode().split('\n')
		sub.stdout.close()
		print("root:",res[0])
		print("video:",res[1])
	elif '7' in sys_num:
		sub = subprocess.Popen("df -lh|grep -w /|awk '{print $5}'&&df -lh|grep video|awk '{print $5}'&&df -lh|grep -w /|awk '{print $2}'&&df -lh|grep video|awk '{print $2}'",stdout=subprocess.PIPE,shell=True)
		res = sub.stdout.read().decode().split('\n')
		sub.stdout.close()
		print("root:",res[0])
		print("video:",res[1])

if __name__ == "__main__":
	get_disk()
