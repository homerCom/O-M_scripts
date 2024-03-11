#!/usr/bin/python
#coding:utf-8
# 获取风霆迅云端酒店数据总表

#import xlsxwriter
import sys
import time
import os
import urllib, json
import ftplib
reload(sys)
sys.setdefaultencoding('utf-8')

#today = time.strftime("%y%m%d")
#localfile='/tmp/ftxHotelInfo_'+today+'.xlsx'
#workbook = xlsxwriter.Workbook(localfile)
#boldtitle = workbook.add_format({'bold':True,'border':1,'align':'center','fg_color':'#D7E4BC'})
#bold = workbook.add_format({'border':1})
#bold = workbook.add_format({'bold':True})
#
#worksheet = workbook.add_worksheet('云端总表')
#worksheet.autofilter('A1:M1')
#worksheet.freeze_panes(1, 0)
#worksheet.set_column('A:C',30)
#worksheet.set_column('D:M',15)
#worksheet.write('A1','酒店名称',boldtitle)
#worksheet.write('B1','备注名称',boldtitle)
#worksheet.write('C1','酒店地址',boldtitle)
#worksheet.write('D1','房间数量',boldtitle)
#worksheet.write('E1','所属集团',boldtitle)
#worksheet.write('F1','商户分类',boldtitle)
#worksheet.write('G1','播放模式',boldtitle)
#worksheet.write('H1','酒店key',boldtitle)
#worksheet.write('I1','key状态',boldtitle)
#worksheet.write('J1','影片总数：',boldtitle)
#worksheet.write('K1','id',boldtitle)
#worksheet.write('L1','联系人',boldtitle)
#worksheet.write('M1','联系电话',boldtitle)

limit=500
url = 'http://127.0.0.1/api/third/episode/list?pageSize='+str(limit)
response = urllib.urlopen(url)
data = json.loads(response.read())
myhotel = data['data']['result']
for i in range(len(myhotel)):
        print myhotel[i]['displayName']
print
print "影片总数：",data['data']['totalCount']
#        worksheet.write(i+1,0,myhotel[i]['vpn_cinema_name'])    #酒店名称       vpn_cinema_name
#        worksheet.write(i+1,1,myhotel[i]['remarks'])            #备注名称       remarks
#        worksheet.write(i+1,2,myhotel[i]['addr'])               #酒店地址       addr
#        worksheet.write(i+1,3,myhotel[i]['rooms'])              #房间数量       rooms
#        worksheet.write(i+1,4,myhotel[i]['group'])              #所属集团       group
#        worksheet.write(i+1,5,myhotel[i]['class'])              #商户分类       class
#        worksheet.write(i+1,6,myhotel[i]['play_module'])        #播放模式       play_module
#        worksheet.write(i+1,7,myhotel[i]['host_name'])          #酒店key        host_name
#        worksheet.write(i+1,8,myhotel[i]['status'])             #key状态        status
#        worksheet.write(i+1,9,myhotel[i]['film_count'])         #影片总数       film_count
#        worksheet.write(i+1,10,myhotel[i]['id'])                #id             id
#        worksheet.write(i+1,11,myhotel[i]['contacter'])         #联系人         contacter
#        worksheet.write(i+1,12,myhotel[i]['phone'])             #联系电话       phone
#workbook.close()
#
## FTP
#print 'start to upload'
#f = ftplib.FTP('219.146.255.198','travelink','haier123')
#f.cwd('/mnt/backup/xlsx')
#fp = open(localfile, 'rb')
#filename=localfile[5:]
#f.storbinary('STOR ' +filename,fp,1024)
#
#fp.close()
#f.quit()
#
#os.remove(localfile)
#print 'done'
