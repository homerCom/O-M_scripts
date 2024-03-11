#!/usr/bin/python2.7
#-*- coding:utf-8 -*-

import platform
import os
import sys
import re
import urllib, json
import pymysql
import xlrd
import psutil
reload(sys)
sys.setdefaultencoding('utf-8')

# 获取数据库信息
def getDbInfo(houtai):
        with open(os.path.join("/var/www/",houtai,"config.php")) as f:
                for line in f.readlines():
                        if 'DB_USER' in line:
                                dbuser=line.split("'")[3]
                        if 'DB_PWD' in line:
                                dbpwd=line.split("'")[3]
                dbInfo=[dbuser,dbpwd]
        return dbInfo

def getHotelInfo(excelNo):
	url="http://219.146.255.198:8098/share/0xsserver/xsserver.xlsx"
    	urllib.urlretrieve(url, "xsserver.xlsx")
	wb=xlrd.open_workbook('xsserver.xlsx')
	ws=wb.sheet_by_index(0)
	hotelinfo=ws.row_values(int(excelNo)-1)
	return hotelinfo

def checkMovieCount():
        db = pymysql.connect(host="127.0.0.1",port=3306,db='localplay',charset='utf8')
        cursor = db.cursor()
        cursor.execute("select count(display_name) from local_episode where online_status=1 and playable=1;")
        data = cursor.fetchall()
        if data[0][0] > 250:
		print "影片数量",data[0][0],"[OK]"
	else:
		print "影片数量",data[0][0],"[Fail]"
		sys.exit()

def checkip():
	iqiyiurllist=[]
	ipaddrlist=[]

	# eth ip
        with open("/etc/sysconfig/network-scripts/ifcfg-eth0") as f:
                mylist = f.read().splitlines()
                for line in mylist:
                         if "IPADDR" in line:
                                ipaddr=line.split("=")[1]

	# iqiyi url
        db = pymysql.connect(host="127.0.0.1",port=3306,db='localplay',charset='utf8')
        cursor = db.cursor()
        cursor.execute("select m3u8_url from local_episode where online_status=1 and playable=1;")
        data = cursor.fetchall()
	for url in data:
		iqiyiurl=re.split('[:/]',url[0])[3]
		iqiyiurllist.append(iqiyiurl)

        cursor.execute("select p_value from local_property where p_key = 'ip'")
        data = cursor.fetchall()
	for value in data:
		 iqiyiurllist.append(value[0])

	for ip in ipaddrlist:
		if ipaddr!=ip:
			print "\033[1;31;40mipcheck error,fix it\033[0m"
			print "/opt/iqiyi/tool/jiami/update_IP.sh.x"
			sys.exit()

def check_hardware():
	mem_size=psutil.virtual_memory().total /1000/1000/1000
	netcard_num=len(psutil.net_if_addrs())-2
		
	hotelInfo=getHotelInfo(excelNo)
	local_peizhi=hotelInfo[16]
	print "配置：",local_peizhi
	print "内存容量：",mem_size
	print "网卡数量：",netcard_num

	if local_peizhi=='低配':
		if mem_size!=8:
			print "本机内存：",mem_size,"G"
			sys.exit()
		if netcard_num!=1:
			print "网卡数量：",netcard_num
			sys.exit()
	elif local_peizhi=='高配':
		if mem_size!=16:
                        print "本机内存：",mem_size,"G"
                        sys.exit()
		if netcard_num!=2:
			print "网卡数量：",netcard_num
			sys.exit()
	else:
		print local_peizhi,"没有值"
		sys.exit()

# 获取iqiyi版本
def getiqiyiversion():
        with open('/data/moviebar/moviebar.war') as f:
	        alltxt=f.readlines()
        	version=alltxt[12].split(":")[1].strip()
        	print "爱奇艺版本：",version  

# 获取小帅后台信息
def getHoutaiInfo(houtai):
        with open(os.path.join("/var/www/",houtai,"admin/template/admin/login.html")) as myfile:
                if '8888' in myfile.read():
                        print "小帅后台版本：2.0"
                else:
                        print "小帅后台版本：3.0"

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
		print
                print "设备传来"
                print "{} --> {}".format("房间数",data['count'])
                for roomdict in data['data']:
                        print roomdict['hotelName'],roomdict['room'],roomdict['productCode'],roomdict['EthernetMac'],roomdict['wifiMac'],roomdict['utime']
	
        cursor.execute("select * from d_config where name in ('default_server','localVpnip','projectName','hotel_id','hotel_username','telckey','hz_hotel_id');")
        data = cursor.fetchall()
	print
	print "{} --> {}".format(houtai,"d_config"),
        for i in data:
                print
                for j in i:
                        print j,

	cursor.execute("SELECT mf.morder,mf.mname,mf.attr,mf.bljlm,ma.name as attrName FROM h_menu mf left join h_menuattr ma on mf.attr=ma.attr WHERE mf.pid=0 and (mf.attr=1 or mf.attr=99 ) order by mf.morder;")
	data = cursor.fetchall()
	print
	print
	print "{} --> {}".format(houtai,"新界面目录"),
	for i in data:
		print
                for j in i:
                        print j,

        cursor.execute("select m.morder,l.content from h_language l left join h_menu m on l.mid=m.id where l.type in (1,2) and m.attr in (1,99) and m.pid=0 order by m.morder,l.type;")
        data = cursor.fetchall()
	print
	print
        print "{} --> {}".format(houtai,"中英文目录"),
        for i in data:
                print
                for j in i:
                        print j,

        cursor.execute("SELECT id,apkName,serviceName,version FROM h_service_list WHERE 1")
        data = cursor.fetchall()
	print
	print
        print "{} --> {}".format(houtai,"服务配置"),
        for i in data:
                print
                for j in i:
                        print j,

        cursor.execute("select id,music_name,music_addr,state,md5 from h_music;")
        data = cursor.fetchall()
        print
        print
        print "{} --> {}".format(houtai,"下载配置"),
        for i in data:
                print
                for j in i:
                        print j,

        cursor.execute("select id,uname,intro,dataVersion,module,roomStr,stime from h_update_version;")
        data = cursor.fetchall()
        print
        print
        print "{} --> {}".format(houtai,"版本控制"),
        for i in data:
                print
                for j in i:
                        print j,

        cursor.execute("select * from h_canshu where name in ('电影IP地址','酒店留言滚动');")
        data = cursor.fetchall()
        print
        print
        print "{} --> {}".format(houtai,"电影IP地址，酒店滚动留言"),
        for i in data:
                print
                for j in i:
                        print j,

        cursor.execute("select * from h_weather;")
        data = cursor.fetchall()
        print
        print
        print "{} --> {}".format(houtai,"天气设置"),
        for i in data:
                print
                for j in i:
                        print j,

        cursor.execute("select a.apk_code,a.apk_name,apk_package,f.platform_name from h_apk a left join h_apk_platform f on a.apk_platform=f.platform_num order by f.platform_name,apk_package;")
        data = cursor.fetchall()
	print
	print
	print "{} --> {}".format(houtai,"apk信息")
	print "版本号 apk名 平台",
        for i in data:
                print
                for j in i:
                        print j,

        cursor.execute("select r.*,a.platform_name from h_rooms_conf r left join h_apk_platform a on r.platform=a.platform order by r.rname;")
        data = cursor.fetchall()
	print
	print
	print "{} --> {}".format(houtai,"本地设备信息")
	print "id | rname | alive | ipaddr | mac | platform | model | platform_name",
        for i in data:
                print
                for j in i:
                        print j,

        cursor.execute("select count(rname),r.platform,a.platform_name from h_rooms_conf r left join h_apk_platform a on r.platform=a.platform group by r.platform;")
        data = cursor.fetchall()
	print
	print
	print "count(rname) | platform | platform_name",
        for i in data:
                print
                for j in i:
                        print j,

def getIqiyiInfo():
        db = pymysql.connect(host="127.0.0.1",port=3306,db='localplay',charset='utf8')
        cursor = db.cursor()
        cursor.execute("select id,name,agent_code,auth_start_time,auth_end_time,cinema_num,auth_status from local_bar")
        data = cursor.fetchall()
        print
	print "-"
        print "id | name | agent_code | auth_start_time | auth_end_time | cinema_num | auth_status",
        for i in data:
                print
                for j in i:
                        print j,

        cursor.execute("select type,p_value from local_property where p_key = 'ip'")
        data = cursor.fetchall()
        print
	print "-"
        print "type | p_value",
        for i in data:
                print
                for j in i:
                        print j,

        cursor.execute("select cinema_code,device_code from local_device;")
        data = cursor.fetchall()
	print "-"
        print "cinema_code | device_code",
        for i in data:
                print
                for j in i:
                        print j,

        cursor.execute("select m3u8_url,display_name from local_episode where online_status=1 and playable=1;")
        data = cursor.fetchall()
        print
	print "-"
        print "m3u8_url | display_name",
        for i in data:
                print
                for j in i:
                        print j,

        cursor.execute("select count(display_name) from local_episode where online_status=1 and playable=1;")
        data = cursor.fetchall()
        print
	print "-"
        print "影片数量：",data[0][0]
	print
        cursor.execute("select p_value from local_property where type='property' and p_key like 'download%';")
        data = cursor.fetchall()
        print "下载开始时间：{} 下载结束时间：{}".format(data[0][0],data[1][0])
        cursor.execute("select cinema_num from localplay.local_bar")
        data = cursor.fetchall()
        print
        print "授权数量：",data[0][0],
        cursor.execute("select count(*) from localplay.local_device")
        data = cursor.fetchall()
        print "已注册：",data[0][0]

if __name__ == "__main__":
	if len(sys.argv) != 2:
		print '格式：脚本名 excel序号'
		sys.exit(1)

	excelNo=sys.argv[1]

	print "1.检查电影数量"
	checkMovieCount()
	print
	print "2.检查服务器硬件"
	check_hardware()
	print
	print "3.IP验证"
	checkip()
	print "IP [OK]"
	print
	hotelInfo=getHotelInfo(excelNo)
	print "电视型号：",hotelInfo[4],hotelInfo[5]
	os.remove('xsserver.xlsx')

