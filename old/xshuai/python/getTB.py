#!/usr/bin/env python
# -*- encoding: utf-8 -*-

import requests
import re
import xlsxwriter

#获取网页,参数：搜索名称，第几页
def get_html(goods, pages):
    pages = str((pages - 1)*44)

    url="https://s.taobao.com/search?q=" + goods + "&imgfile=&commend=all&ssid=s5-e&search_type=item&sourceId=tb.index&spm=a21bo.2017.201856-taobao-item.1&ie=utf8&initiative_id=tbindexz_20170306&bcoffset=3&ntoffset=3&p4ppushleft=1%2C48&sort=sale-desc&s=" + pages

    headers ={
        "user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Safari/537.36",
        "cookie":"cna=SvFhGILdrxACAduS/8Z58ncr; tracknick=\\u9676\\u6D9B369; enc=E12iY9sVLI5Yo14PSCcBoIx5s8XuQFqY+xfhtHGLZt/085IZ4uoNN1ljRIkldqn9rWl5fM6Tc4kHtbWsuH8Zrg==; thw=cn; hng=CN|zh-CN|CNY|156; miid=374436301623058167; t=5b604c54b4cb2cd662f6a8446826aa67; _tb_token_=e3f1671e53391; _m_h5_tk=62d3ba279729d6b8576d37219daa050e_1614855863534; _m_h5_tk_enc=f4594054930c4e4ca0c648b46d3c2797; xlly_s=1; alitrackid=www.taobao.com; lastalitrackid=www.taobao.com; cookie2=16ea082f2af4af5748cb1b02143cfeec; _samesite_flag_=true; sgcookie=E100rBD8Y2DqGp+E+pPr2QGLtxk1IxRtBWWa1Et0GdJhDnAS5/4TyTvrMQpcyviUoMB2FSXRfA4LZV1c+EPzYc++SQ==; unb=763950883; uc3=vt3=F8dCuAVnQZvaXtomuIY=&lg2=WqG3DMC9VAQiUQ==&id2=VAcN6x0Uekh1&nk2=r4BTJFpDAA==; csg=83af3a40; lgc=\\u9676\\u6D9B369; cookie17=VAcN6x0Uekh1; dnk=\\u9676\\u6D9B369; skt=b5235b69d22e97fb; existShop=MTYxNDg0NzI0MQ==; uc4=nk4=0@rWKCRTxEokfABfBW71T8Sisd&id4=0@Vh5PLn1PBCLiGk8tWYj/4FME2w4=; publishItemObj=Ng==; _cc_=V32FPkk/hw==; _l_g_=Ug==; sg=934; _nk_=\\u9676\\u6D9B369; cookie1=AQdxBfXp1NAfEYWTsqRoiofr5yd1HYyy39dvEUmQbl4=; v=0; mt=ci=72_1; uc1=cookie14=Uoe1hg5Ujaj7fA==&cookie15=URm48syIIVrSKA==&existShop=false&pas=0&cookie21=VT5L2FSpdet1FS8C2gIFaQ==&cookie16=VFC/uZ9az08KUQ56dCrZDlbNdA==; JSESSIONID=44351C021BD79505F8C936E24544CD13; tfstk=cEu5BOawlTX7k-KFzbOVzOWKuIaOaM1_O3woN0PxrkLGI6G7HsDA7RMwxDXdklFf.; l=eBaE-CvPOVxF6O6DBO5Cnurza77T4Idb8sPzaNbMiInca69R1p8lkNCQMngXRdtjgt5vGetzDhlo8dHe5xz_WAGjL77kRs5mpnpw-e1..; isg=BIyMXsBEAJ9D5St_ij8UEDBFXeq-xTBvL-OwLuZMRTeNcS17Dtdh_faLFXnJOWjH",
        "accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
    }
    html = requests.get(url,headers=headers).text
    return html

def writeToExcel(html):
    global count
    title = re.findall(r'"raw_title":"(.*?)"', html)#标题
    price = re.findall(r'"view_price":"(.*?)"', html)#价格
    sales = re.findall(r'"view_sales":"(.*?)"', html)#卖出数量
    store = re.findall(r'"nick":"(.*?)"', html)#店铺名称
    local = re.findall(r'"item_loc":"(.*?)"', html)#地址
    url = re.findall(r'"detail_url":"(.*?)"', html)#详情连接

    new_url = []
    new_sales = []
    #生成正确的详情连接
    for i in url:
        j = i.replace("//","").replace("\\u003d","=").replace("\\u0026","&")
        new_url.append(j)

    #去掉多余字符“人收货”
    for s in sales:
        s = s[:-3]
        new_sales.append(s)
    
    #所有数据集合在一个列表中
    all = []
    for i in range(len(title)):
        all.append([title[i],price[i],new_sales[i],store[i],local[i],new_url[i]])
    # print(all)

    for i in range(len(all)):
        worksheet.write(count+i+1,0,count+i+1)
        worksheet.write(count+i+1,1,all[i][0])
        worksheet.write(count+i+1,2,all[i][1])
        worksheet.write(count+i+1,3,all[i][2])
        worksheet.write(count+i+1,4,all[i][3])
        worksheet.write(count+i+1,5,all[i][4])
        worksheet.write(count+i+1,6,all[i][5])
    count = count + len(all)

if __name__ == "__main__":
    count = 0
    name = input("输入商品名称：")
    page = int(input("输入要爬取的页数："))

    workbook = xlsxwriter.Workbook(name+'.xlsx')
    worksheet = workbook.add_worksheet()
    worksheet.write('A1',"编号")
    worksheet.write('B1',"标题")
    worksheet.write('C1',"价格")
    worksheet.write('D1',"销量")
    worksheet.write('E1',"店铺")
    worksheet.write('F1',"地址")
    worksheet.write('G1',"链接")
    for i in range(1,page+1):
        print("正在爬取第%s页"%i)
        html = get_html(name, i)
        print(html)
        writeToExcel(html)

    workbook.close()