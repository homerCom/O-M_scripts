#!/usr/bin/python2.7
#coding:utf-8
# 功能：所有房间目前的版本号

import pymysql
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

db = pymysql.connect(host="127.0.0.1",port=3306,user="xiaoshuai",passwd="travelink",db="tlkcs",charset='utf8')
cursor = db.cursor()
cursor.execute("select d.roomNo,d.stime,d.state,d.intro,v.intro from h_update_data d left join h_update_version v on d.intro=v.dataVersion where d.id in (select max(d.id) from h_update_data d group by d.roomNo);")
data = cursor.fetchall()
print 
print "房间号","更新时间","更新状态","当前版本","更新内容"
for i in range(len(data)):
        print data[i][0],data[i][1],
	if data[i][2]==2:
		print "正常",
	else:
		print "异常",
	print data[i][3],data[i][4]
print
