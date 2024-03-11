#!/usr/bin/python
#coding:utf-8
# 功能：传入一个参数，获得一个房间的升级历史数据

import MySQLdb
import sys
import os
import json
reload(sys)
sys.setdefaultencoding('utf-8')

if len(sys.argv) != 2:
        print "参数error"
        sys.exit(1)

roomNo=sys.argv[1]
db = MySQLdb.connect(host="127.0.0.1",port=3306,user="root",passwd="123456",db="tlkcs",charset='utf8')
cursor = db.cursor()
cursor.execute("select id,other,intro,stime,data from h_update_data where roomNo='"+roomNo+"';")
data = cursor.fetchall()
for i in range(len(data)):
        print
        print 'id:',data[i][0],'\t',data[i][1],"--->",data[i][2],'\t',data[i][3]
        updatedata=data[i][4]
        myupdatedata=json.loads(updatedata)
        print "-- apk"
        if myupdatedata['apk']:
                for j in range(len(myupdatedata['apk'])):
                        print myupdatedata['apk'][j]['title'],myupdatedata['apk'][j]['addr']
        print "-- music"
        if myupdatedata['music']:
                for j in range(len(myupdatedata['music'])):
                        print myupdatedata['music'][j]['title'],myupdatedata['music'][j]['addr']
        print "-- pic"
        if myupdatedata['pic']:
                for j in range(len(myupdatedata['pic'])):
                        print myupdatedata['pic'][j]['title'],myupdatedata['pic'][j]['addr']
