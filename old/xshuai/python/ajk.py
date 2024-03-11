#!/usr/bin/env python
# -*- encoding: utf-8 -*-
'''
@File    :   ajk.py
@Time    :   2021/03/10 11:02:08
@Author  :   Homer
@Version :   1.0
@Contact :   since199310@163.com
'''

import requests
import re
from bs4 import BeautifulSoup
import xlsxwriter

def getOnePage(url):
    page_list = []
    response = requests.get(url, headers=headers)
    soup = BeautifulSoup(response.content,"html.parser")
    all = soup.find_all('a',class_ = "property-ex")
    for item in all:
        link = item.get('href')#详细连接
        title = item.find(class_ = 'property-content-title-name').text#标题
        info = item.find_all(class_ = 'property-content-info-text')
        shi = info[0].text.split()[0]#几室
        mj_1 = info[1].text.split('\n')[1]
        mj = re.sub(' ','',mj_1)#面积
        # date_1 = info[4].text
        # date = re.sub(' ','',date_1.split('\n')[1])[0:4]#建造时间
        price = item.find(class_ = 'property-price-total').text#总价
        price_av = item.find(class_ = 'property-price-average').text[:-3]#单价
        xiaoqu = item.find(class_ = 'property-content-info-comm-name').text#小区名称
        dizhi = item.find(class_ = 'property-content-info-comm-address').text#详细地址
        # zj_name = item.find(class_ = 'property-extra').text.split()[0]#中介姓名
        # score = item.find(class_ = 'property-extra').text.split()[1]#评分
        # zj_gongsi = item.find(class_ = 'property-extra').text.split()[2]#中介公司
        # sigle_list = [title,mj,price,price_av,shi,dizhi,xiaoqu,date,zj_name,zj_gongsi,score,link]
        page_list.append([title,mj,price,price_av,shi,dizhi,xiaoqu,link])
    return page_list

def toExcel(all):
    workbook = xlsxwriter.Workbook('安居客1-{}页.xlsx'.format(pages))
    worksheet = workbook.add_worksheet()
    worksheet.write('A1',"标题")
    worksheet.write('B1',"面积")
    worksheet.write('C1',"价格")
    worksheet.write('D1',"单价")
    worksheet.write('E1',"几室")
    worksheet.write('F1',"地址")
    worksheet.write('G1',"小区名称")
    worksheet.write('H1',"详情页")
    for i in range(len(all)):
        worksheet.write(i+1,0,all[i][0])
        worksheet.write(i+1,1,all[i][1])
        worksheet.write(i+1,2,all[i][2])
        worksheet.write(i+1,3,all[i][3])
        worksheet.write(i+1,4,all[i][4])
        worksheet.write(i+1,5,all[i][5])
        worksheet.write(i+1,6,all[i][6])
        worksheet.write(i+1,7,all[i][7])
    workbook.close()

if __name__ == '__main__':
    headers = {
    "Accept":"application/json, text/plain, */*",
    "user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36",
    "cookie":"sessid=A879EB14-61C0-BF6E-3A9D-056F4BD3D5C8; aQQ_ajkguid=33BB8062-8A83-7831-967F-D369A61C1C0D; ctid=30; twe=2; id58=e87rkGBIKQROmqm7AxIZAg==; _ga=GA1.2.1665565618.1615341827; _gid=GA1.2.1716504976.1615341827; wmda_uuid=21b496bd2a1e77df9d66a88187946850; wmda_new_uuid=1; wmda_visited_projects=;6289197098934; 58tj_uuid=6c717b2e-98ce-468d-83b5-02f599a34378; als=0; wmda_session_id_6289197098934=1615344386341-822839a9-74bc-9129; init_refer=https%3A%2F%2Fwww.baidu.com%2Fother.php%3Fsc.a00000K4_715YUjSqVnCVVKwbczKlIwU_tBJv1SoJwkTUOASp5TeOPg1Cc81qgdCxZy1ExNW7nVocTnIvvlvWXcnQlIHZa3TfnEWQKJle3oAI6YgcL0nEXCgD-aLuCMOsRHaF_2ZgXaDhEZR2xTeUU2Mtc827EA3x_TqaCMriw9LvtJ5yZgPRIsKCC52x_WwicksXCV2YO55y0ACZFtz7QUjUSzO.DY_NR2Ar5Od663rj6thm_8jViBjEWXkSUSwMEukmnSrZr1wC4eL_8C5RojPak3S5Zm0.TLFWgv-b5HDkrfK1ThPGujYknHb0THY0IAYq_Q2SYeOP0ZN1ugFxIZ-suHYs0A7bgLw4TARqnsKLULFb5UazEVrO1fKzmLmqnfKdThkxpyfqnHRzPjTLPjbLnsKVINqGujYkPjcYPHbLn0KVgv-b5HDsrjbznj0v0AdYTAkxpyfqnHczP1n0TZuxpyfqn0KGuAnqHbG2RsKWThnqPWcdPHT%26ck%3D8311.7.96.337.163.553.157.128%26dt%3D1615341824%26wd%3D%25E5%25AE%2589%25E5%25B1%2585%25E5%25AE%25A2%26tpl%3Dtpl_12273_24677_20875%26l%3D1524774973%26us%3DlinkName%253D%2525E6%2525A0%252587%2525E9%2525A2%252598-%2525E4%2525B8%2525BB%2525E6%2525A0%252587%2525E9%2525A2%252598%2526linkText%253D%2525E5%2525AE%252589%2525E5%2525B1%252585%2525E5%2525AE%2525A2-%2525E5%252585%2525A8%2525E6%252588%2525BF%2525E6%2525BA%252590%2525E7%2525BD%252591%2525EF%2525BC%25258C%2525E6%252596%2525B0%2525E6%252588%2525BF%252520%2525E4%2525BA%25258C%2525E6%252589%25258B%2525E6%252588%2525BF%252520%2525E6%25258C%252591%2525E5%2525A5%2525BD%2525E6%252588%2525BF%2525E4%2525B8%25258A%2525E5%2525AE%252589%2525E5%2525B1%252585%2525E5%2525AE%2525A2%2525EF%2525BC%252581%2526linkType%253D; new_uv=2; isp=true; new_session=0; lp_lt_ut=271ec161dc80635409996b4eb0c91b24; xxzl_cid=c9174e4200344e52b094988728dd02ab; xzuid=76c5738f-6030-4437-83f3-9819ece70003; obtain_by=2"
    }
    pages = 17
    all = []
    for page in range(1,pages+1):
        url = 'https://qd.anjuke.com/sale/p' + str(page) + '/?from=navigation'
        tmp = getOnePage(url)
        for i in range(len(tmp)):
            all.append(tmp[i])
        print('第{}页抓取完毕。'.format(page))

    print("爬取完毕,开始写入excel表格")
    toExcel(all)