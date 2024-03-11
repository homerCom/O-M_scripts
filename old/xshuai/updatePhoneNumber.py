#!/usr/bin/python3
# -*- coding: utf-8 -*-

import pymysql
import platform
import sys

version = platform.platform()
if "centos-6.6" in version:
        passwd = '123456'
else:
        passwd = 'travelink'

conn = pymysql.connect(host='localhost',user='root',password=passwd,port=3306,db='tlkcs',charset='utf8')
cursor = conn.cursor()
chaxun_sql = "select x from h_canshu where id=26"
cursor.execute(chaxun_sql)
startInfo = cursor.fetchall()[0][0]
info = startInfo.replace("4008740088","4009009710")
conn.close()

if "09710" in startInfo:
	print("电话信息已更新，无需再次修改!")
	sys.exit()
else:
	db = pymysql.connect(host='localhost',user='root',password=passwd,port=3306,db='tlkcs',charset='utf8')
	cursor1 = db.cursor()
	update_sql = 'update h_canshu set x="%s" where id=26' % (info)
	try:
		cursor1.execute(update_sql)
		db.commit()
		cursor1.execute(chaxun_sql)
		info = cursor1.fetchall()[0][0]
		print(info)
		print("更新成功.")
	except Exception as e:
		db.rollback    
		print(str(e))
		print("更新失败!")
	db.close()
