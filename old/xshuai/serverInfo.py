#!/usr/bin/python3
# -*- coding:UTF-8 -*-
#注释：获取服务器信息

import subprocess

def get_disk():
	with open("/etc/redhat-release",'r') as f:
		#print(f.read().replace("\n",''))
		sys_num = f.read().replace("\n",'')
		f.close()
	if '6.6' in sys_num:
		sub = subprocess.Popen("df -lh|grep -w /|awk '{print $4}'&&df -lh|grep -w /video|awk '{print $4}'&&df -lh|grep -w /|awk '{print $1}'&&df -lh|grep -w /video|awk '{print $1}'",stdout=subprocess.PIPE,shell=True)
		res = sub.stdout.read().decode().split('\n')
		sub.stdout.close()
		return res
	elif '7' in sys_num:
		sub = subprocess.Popen("df -lh|grep -w /|awk '{print $5}'&&df -lh|grep video|awk '{print $5}'&&df -lh|grep -w /|awk '{print $2}'&&df -lh|grep video|awk '{print $2}'",stdout=subprocess.PIPE,shell=True)
		res = sub.stdout.read().decode('utf-8').split('\n')
		sub.stdout.close()
		return res

def get_info(cmd):
	sub = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)
	res = sub.stdout.read().decode('utf-8').split('\n')
	sub.stdout.close()
	return res

if __name__ == "__main__":
	disk = get_disk()
	print(disk)
	ip_cmd = "ip a |grep brd|grep global|awk '{print $2}'|awk -F '/' '{print$1}'&&curl -s cip.cc|grep -w IP|awk '{print $3}'&&ip a |grep 10.8|awk '{print$2}'&&ip a |grep 10.7|awk '{print$2}'"
	ip = get_info(ip_cmd)
	print(ip)
	mem_cmd = "dmidecode | grep '^[[:space:]]*Size.*MB$' | uniq -c | sed 's/ \t*Size: /\*/g' | sed 's/^ *//g'|xargs -n 20"
	mem = get_info(mem_cmd)
	print(mem)
	sn_cmd = "dmidecode |grep -A 4 'System Information'|grep 'Serial Number'|awk '{print $3}'&&dmidecode |grep 'String 7'|cut -b 15-24"
	sn = get_info(sn_cmd)
	print(sn)
	name_cmd = "dmidecode |grep -A 2 'System Information'|grep Manu|awk '{print$2}'&&dmidecode |grep -A 2 'System Information'|grep Product|awk '{print$4}'"
	name = get_info(name_cmd)
	print(name)
