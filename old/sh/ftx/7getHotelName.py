#!/usr/bin/python
#-*- coding:utf-8 -*- 
# 获取风霆迅酒店信息

import urllib, json
import sys
import os
import commands
import MySQLdb
reload(sys)
sys.setdefaultencoding( "utf-8" )
if os.path.exists('/dev/shm/mysql.sock'):
	hostname=commands.getoutput("ls /etc/openvpn/ | awk -F '.' '/^xs.*crt$/{print $1}'")
else:
	hostname=commands.getoutput('hostname')
#key=sys.argv[1]
url = 'http://hotel.ftxjoy.com/index.php/Home/Interface/index?class=Api&method=getHotelInfo&params={"key":"'+hostname+'","num":"1","p":"1"}'
response = urllib.urlopen(url)
data = json.loads(response.read())
myhotel = data['data']['data_list']

if myhotel['remarks']:
        for key in myhotel:
                print key+":"+myhotel[key]
else:
        sys.exit(1)

print
if os.path.exists('/dev/shm/mysql.sock'):
	db = MySQLdb.connect(host="localhost",port=23306,user="root",passwd="123456",db="mictic",charset='utf8',unix_socket='/dev/shm/mysql.sock')
else:
	db = MySQLdb.connect(host="localhost",port=3306,user="root",passwd="123456",db="mictic",charset='utf8')
cursor = db.cursor()
cursor.execute("select count(*) from mt_video_box where hall_id <> 0")
data = cursor.fetchall()
print "风霆迅已注册：",data[0][0]
