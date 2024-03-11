#!/usr/bin/python2.7
#-*- coding:utf-8 -*-

import platform
import os
import urllib2, json
from subprocess import Popen, PIPE
from datetime import datetime
from requests import get
import salt.config
import salt.loader
import salt.client

try:
        import MySQLdb as xsmysql
except ImportError:
        try:
                import pymysql as xsmysql
        except ImportError:
                print "error"

# 获取服务器型号
#def getProductName():
#	process = Popen(['dmidecode'], stdout=PIPE, stderr=PIPE)
#	stdout, stderr = process.communicate()
#
#	for line in stdout.splitlines():
#        	if "Product Name" in line:
#                	productName=line.split(":")[1]
#                	break
#	productdict={'productName':productName}
#	return productdict

def getPublicIP():
	ip = get('https://api.ipify.org').text
	ipdict = {'publicip':ip}
	return ipdict

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
	mem_total=__grains__['mem_total']
	
	grainsdict=dict(osrelease=osrelease,mem_total=mem_total,saltversioninfo=saltversioninfo,id=id,num_cpus=num_cpus,ip4_interfaces=ip4_interfaces,osfinger=osfinger)
	return grainsdict
	
# 获取小帅后台信息
def getXsInfo(houtai):
	dbInfo=getDbInfo(houtai)
        db = xsmysql.connect(host="127.0.0.1",port=3306,user=dbInfo[0],passwd=dbInfo[1],db=houtai,charset='utf8')
        cursor = db.cursor()

	# hotelname
        cursor.execute("select config from d_config where name='hotel_username';")
        data = cursor.fetchall()
	hotelname=data[0][0]

        cursor.execute("select x from h_canshu where name='酒店留言滚动' and y=1;")
        data = cursor.fetchall()
	marquee=data[0][0]

	# apk info
        cursor.execute("select a.apk_code,a.apk_name,apk_package,f.platform_name from h_apk a left join h_apk_platform f on a.apk_platform=f.platform_num order by f.platform_name,apk_package;")
	row_headers=[x[0] for x in cursor.description] #this will extract row headers
        data = cursor.fetchall()
	xshuaidict={}
	apk_data=[]
   	for result in data:
		apk_data.append(dict(zip(row_headers,result)))

	# menu info
	cursor.execute("select m.morder AS morder1,m.mname,m.attr,n.morder AS morder2,n.mname,n.attr,n.bljlm,k.apk_name from h_menu m left join h_menu n on m.id=n.pid left join h_apk k on k.apk_package=n.bljlm where m.attr=1 UNION select m.morder AS morder1,m.mname,m.attr,n.morder AS morder2,n.mname,n.attr,n.bljlm,k.apk_name from h_moviemenu m left join h_moviemenu n on m.id=n.pid left join h_apk k on k.apk_package=n.bljlm where n.attr=11 or n.attr=99 order by morder1,morder2;")

	row_headers=[x[0] for x in cursor.description]
	data = cursor.fetchall()
	menu_data=[]
   	for result in data:
        	menu_data.append(dict(zip(row_headers,result)))

	# menu info1
	cursor.execute("show tables like 'h_menuattr'")
	result = cursor.fetchone()
	if result:
		cursor.execute("SELECT mf.morder,mf.mname,mf.attr,mf.bljlm,ma.name as attrName FROM h_menu mf left join h_menuattr ma on mf.attr=ma.attr WHERE mf.pid=0 and (mf.attr=1 or mf.attr=99) order by mf.morder;")
	row_headers=[x[0] for x in cursor.description]
	data = cursor.fetchall()
	menu_data1=[]
   	for result in data:
        	menu_data1.append(dict(zip(row_headers,result)))
	if menu_data1:
		xshuai_dict={'hotelname':hotelname,'marquee':marquee,'apk_data':apk_data,'menu_data':menu_data,'menu_data1':menu_data1}
	else:
		xshuai_dict={'hotelname':hotelname,'marquee':marquee,'apk_data':apk_data,'menu_data':menu_data}
	return xshuai_dict

# 获取HotelDevice数据
def getRoomInfo(houtai):
        dbInfo=getDbInfo(houtai)
        db = xsmysql.connect(host="127.0.0.1",port=3306,user=dbInfo[0],passwd=dbInfo[1],db=houtai,charset='utf8')
        cursor = db.cursor()
        cursor.execute("select config from d_config where id=20")
        data = cursor.fetchall()
        hotelid = data[0][0]

        url = 'http://h.xshuai.com/manage/port/smac?id='+hotelid
        response = urllib2.urlopen(url)
        data = json.loads(response.read())
	return data

if __name__ == "__main__":
	xsdict={}
	houtaidicts={}
	houtaidict={}
	devicedict={}

	devicedicts={}
	devicedict={}

        for houtai in os.listdir("/var/www/"):
                if houtai.endswith("cs"):
                        houtaidict={houtai:getXsInfo(houtai)}
			houtaidicts.update(houtaidict)
				
			devicedict={houtai:getRoomInfo(houtai)}
			devicedicts.update(devicedict)
	
	xsdict.update({'houtai':houtaidicts})
	xsdict.update({'hoteldevice':devicedicts})

#	xsproductname=getProductName()
#	xsdict.update(xsproductname)

	xsgrains=getGrains()
	xsdict.update(xsgrains)

	inserttime={'inserttime':datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
	xsdict.update(inserttime)

        xsServerInfo=getServerInfo()
        xsdict.update(xsServerInfo)

	xsipdict=getPublicIP()
	xsdict.update(xsipdict)

	req = urllib2.Request('http://update.xshuai.com:25051/hotels')
	req.add_header('Content-Type', 'application/json')
	response = urllib2.urlopen(req, json.dumps(xsdict))
