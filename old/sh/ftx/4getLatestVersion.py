#!/usr/bin/python
#coding:utf-8
# 功能：所有房间目前的版本号

import MySQLdb
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

db = MySQLdb.connect(host="127.0.0.1",port=3306,user="root",passwd="123456",db="tlkcs",charset='utf8')
cursor = db.cursor()
cursor.execute("select intro,group_concat(roomNo) from h_update_data where id in (select max(id) from  h_update_data group by roomNo) group by intro;")
data = cursor.fetchall()
print 
for i in range(len(data)):
        print "版本号",data[i][0],"---->",data[i][1]
print
