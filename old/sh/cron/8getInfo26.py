#!/usr/bin/python
#-*- coding:utf-8 -*-

import platform
import os
import urllib2, json
import MySQLdb
from datetime import datetime
import salt.config
import salt.loader
import salt.client

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

def getServerInfo():
	caller = salt.client.Caller()
	diskusage=caller.sminion.functions['disk.usage']()
	diskdict={'diskinfo':diskusage}
	return diskdict

def getGrains():
	__opts__ = salt.config.minion_config('/etc/salt/minion')
	__grains__ = salt.loader.grains(__opts__)

	osrelease= __grains__['osrelease']
	saltversioninfo=__grains__['saltversioninfo']
	id=__grains__['id']
	num_cpus=__grains__['num_cpus']
	ip4_interfaces=__grains__['ip4_interfaces']
	osfinger=__grains__['osfinger']
	productname=__grains__['productname']
	mem_total=__grains__['mem_total']
	
	grainsdict=dict(osrelease=osrelease,mem_total=mem_total,productname=productname,saltversioninfo=saltversioninfo,id=id,num_cpus=num_cpus,ip4_interfaces=ip4_interfaces,osfinger=osfinger)
	return grainsdict
	
# 获取apk信息
def getApkInfo(houtai):
	dbInfo=getDbInfo(houtai)
        db = MySQLdb.connect(host="127.0.0.1",port=3306,user=dbInfo[0],passwd=dbInfo[1],db=houtai,charset='utf8')
        cursor = db.cursor()
        cursor.execute("select a.apk_code,a.apk_name,apk_package,f.platform_name from h_apk a left join h_apk_platform f on a.apk_platform=f.platform_num order by f.platform_name,apk_package;")
	row_headers=[x[0] for x in cursor.description] #this will extract row headers
        data = cursor.fetchall()
   	json_data=[]
   	for result in data:
        	json_data.append(dict(zip(row_headers,result)))
   	return json_data

if __name__ == "__main__":
	xsdict={}
	xsgrains=getGrains()

        for houtai in os.listdir("/var/www/"):
                if houtai.endswith("cs"):
                        houtaidict={houtai:getApkInfo(houtai)}
			xsdict=dict(xsgrains,**houtaidict)

	inserttime={'inserttime':datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
	xsdict.update(inserttime)

	xsServerInfo=getServerInfo()
	xsdict.update(xsServerInfo)

	req = urllib2.Request('http://update.xshuai.com:25051/hotels')
	req.add_header('Content-Type', 'application/json')
	response = urllib2.urlopen(req, json.dumps(xsdict))
