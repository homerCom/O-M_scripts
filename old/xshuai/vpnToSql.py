#!/usr/bin/python
# -*- coding:utf-8 -*-
#获取服务器vpn信息，存入数据库

import subprocess
import pymysql

count = 0

host = 'localhost'
port = 3306
db = 'vpn'
user = 'root'
password = 'happyview'

db = pymysql.connect(host=host,port=port,db=db,user=user,password=password)
cursor = db.cursor()
#数据库创建命令记录
'''CREATE TABLE IF NOT EXISTS `vpn_list` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hotel_name` varchar(1024) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT '0',
  `ip_addr` varchar(1024) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT '0',
  `xs_key` varchar(1024) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT '0',
 `xs_addr` varchar(1024) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT '0',
 `reserved` varchar(1024) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 ;'''
try:
	cursor.execute("truncate TABLE vpn_list")
	db.commit()
	print("数据库已清除")
except:
	print("数据库清除失败！")

sub = subprocess.Popen("ls /var/www/share/10.8段key/ | grep -v makevpn.sh",stdout=subprocess.PIPE,shell=True)
res = sub.stdout.read().decode().strip().split()

print("开始写入数据......")
for i in range(len(res)):
	name = res[i].split('@')[1]
	vpn = '10.8.' + res[i].split('@')[0]
#	xs_key = res[i].split('@')[2].split('.')[0][9:]
	xs_addr = vpn + ':4396/hclient'
#	sql = """INSERT INTO vpn_list(hotel_name, ip_addr, xs_key, xs_addr) values(%s, %s, %s, %s)"""
	sql = """INSERT INTO vpn_list(hotel_name, ip_addr, xs_addr) values(%s, %s, %s)"""
	try:
#		cursor.execute(sql,(name,vpn,xs_key,xs_addr))
		cursor.execute(sql,(name,vpn,xs_addr))
		db.commit()
	except:
		db.rollback()

	count += 1
print("共计%s条数据，写入完成"%count)
db.close()
