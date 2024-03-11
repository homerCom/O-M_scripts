#!/usr/bin/env python
# -*- encoding: utf-8 -*-
'''
@File    :   tk.py
@Time    :   2021/03/02 11:09:24
@Author  :   Homer
@Version :   1.0
@Contact :   since199310@163.com
'''
from tkinter import Button, Tk, Entry, Text
import pymysql
import requests

##数据库信息
ip = requests.get("http://ip.cip.cc").text.strip('\n')
if ip == '219.146.255.198':
    host = '192.168.1.252'
    port = 3306
else:
    host = '219.146.255.198'
    port = 4006
db_name = 'vpn'
user = 'root'
password = 'happyview'

#查询数据库
def select(info):
    db = pymysql.connect(host=host,port=port,db=db_name,user=user,password=password)
    cursor = db.cursor()
    arg = '%'+info+'%'
    sql = "SELECT * FROM  `vpn_list` WHERE  `hotel_name` LIKE  '%s' OR `ip_addr` LIKE  '%s'"%(arg, arg)
    cursor.execute(sql)
    res = cursor.fetchall()
    db.close()
    return res

#查询函数
def get_entry():
    #清空显示区
    result.delete('1.0','end')
    result.insert('insert',"酒店名称                  VPN地址\n")
    str = input.get()
    res_tup = select(str)
    res_list = list(res_tup)
    for i in res_list:
        li = list(i)
        res = li[1] + '    ' + li[2] + '\n'
        result.insert('insert',res)

#回车按键绑定函数
def get_entry1(event):
    get_entry()

root = Tk()
root.title('小帅VPN查询')
width = 650
height = 650
screenwidth = root.winfo_screenwidth() # 屏幕宽度
screenheight = root.winfo_screenheight() # 屏幕高度
root.geometry('650x650+{}+{}'.format(int((screenwidth - width) / 2), int((screenheight - height) / 2)))
#root.iconbitmap("D:/programs/python/xs.ico")


input = Entry(font=('微软雅黑', 15))
input.place(x=200, y=30, width=250, height=30)
input.focus()#设置默认光标位置

btn = Button(text='查询', command=get_entry)
btn.place(x=400, y=30, width=50, height=30)
root.bind("<Return>",get_entry1)

result = Text(font=('微软雅黑', 15))
result.place(x=100, y=100, width=450, height=500)
root.mainloop()