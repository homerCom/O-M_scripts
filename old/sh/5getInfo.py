#!/usr/bin/python2.7
#-*- coding:utf-8 -*-
# 获取服务器上所有酒店信息

import platform
import os
import urllib, json
import pymysql

# 获取服务器信息
def getDbInfo(houtai):
        with open(os.path.join("/var/www/",houtai,"config.php")) as f:
                for line in f.readlines():
                        if 'DB_USER' in line:
                                dbuser=line.split("'")[3]
                        if 'DB_PWD' in line:
                                dbpwd=line.split("'")[3]
                dbInfo=[dbuser,dbpwd]
        return dbInfo

# 获取酒店房间数据
def getRoomInfo(houtai):
        dbInfo=getDbInfo(houtai)
        db = pymysql.connect(host="127.0.0.1",port=3306,user=dbInfo[0],passwd=dbInfo[1],db=houtai,charset='utf8')
        cursor = db.cursor()
        cursor.execute("select config from d_config where id=20")
        data = cursor.fetchall()
        hotelid = data[0][0]

        url = 'http://h.xshuai.com/manage/port/smac?id='+hotelid
        response = urllib.urlopen(url)
        data = json.loads(response.read())
        if data['result'] == 'true':
                print "房间数：",data['count']
                for roomdict in data['data']:
                        print roomdict['hotelName'],roomdict['room'],roomdict['productCode'],roomdict['EthernetMac'],roomdict['wifiMac'],roomdict['utime']

# 获取操作系统信息
def getOsInfo():
        osname=platform.linux_distribution()[0]
        osrelease=platform.linux_distribution()[1]
        if osrelease=="6.6":
                print "风霆迅主机"
		url = "http://127.0.0.1/Organ/Cron/getInfo"
		response = urllib.urlopen(url)
		data = json.loads(response.read())
		print "风霆迅版本：",data['SYSTEM_VERSION']
        elif osrelease=="6.7":
                print "爱奇艺主机"
        elif osrelease=="7.3":
                print "小帅主机"
        elif osrelease=="12.04":
                print "Ubuntu主机"
        else:
                print "未知"

# 获取后台版本和目录信息
def getHoutaiInfo(houtai):
        with open(os.path.join("/var/www/",houtai,"admin/template/admin/login.html")) as myfile:
                if '8888' in myfile.read():
                        print "小帅后台版本：2.0"
                else:
                        print "小帅后台版本：3.0"

	dbInfo=getDbInfo(houtai)
        db = pymysql.connect(host="127.0.0.1",port=3306,user=dbInfo[0],passwd=dbInfo[1],db=houtai,charset='utf8')
        cursor = db.cursor()
        cursor.execute("select m.morder AS 一级排序,m.mname,m.attr,n.morder AS 二级排序,n.mname,n.attr,n.bljlm from h_menu m left join h_menu n on m.id=n.pid where m.attr=1 UNION select m.morder AS 一级排序,m.mname,m.attr,n.morder AS 二级排序,n.mname,n.attr,n.bljlm from h_moviemenu m left join h_moviemenu n on m.id=n.pid where n.attr=11 or n.attr=99 order by 一级排序,二级排序;")
        data = cursor.fetchall()
	print "一级排序 一级目录 一级属性 二级排序 二级目录 二级属性",
        for i in data:
		print
		for j in i:
			print j,
	cursor.execute("SELECT mf.morder,mf.mname,mf.attr,mf.bljlm,ma.name as attrName FROM h_menu mf left join h_menuattr ma on mf.attr=ma.attr WHERE mf.pid=0 and (mf.attr=1 or mf.attr=99 ) order by mf.morder;")
	data = cursor.fetchall()
	print 
	print 
	print "新界面目录",
	for i in data:
		print
                for j in i:
                        print j,
# 获取apk信息
def getApkInfo(houtai):
	dbInfo=getDbInfo(houtai)
        db = pymysql.connect(host="127.0.0.1",port=3306,user=dbInfo[0],passwd=dbInfo[1],db=houtai,charset='utf8')
        cursor = db.cursor()
        cursor.execute("select a.apk_code,a.apk_name,apk_package,f.platform_name from h_apk a left join h_apk_platform f on a.apk_platform=f.platform_num order by f.platform_name,apk_package;")
        data = cursor.fetchall()
	print
	print "版本号 apk名 平台",
        for i in data:
                print
                for j in i:
                        print j,
	print


if __name__ == "__main__":
        getOsInfo()
	print
        for houtai in os.listdir("/var/www/"):
                if houtai.endswith("cs"):
			print "--> ",houtai
                        getRoomInfo(houtai)
			print
                        getHoutaiInfo(houtai)
			print
                        getApkInfo(houtai)
