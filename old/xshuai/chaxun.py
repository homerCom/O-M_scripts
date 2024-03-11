#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2019/8/9 17:38
# @Author  : Homer
# @Site    : 
# @File    : tuxing.py

from tkinter import Tk,Entry,Label,Button,Text,END,NONE,re
from tkinter import messagebox
from tkinter.filedialog import asksaveasfilename
import pymysql
import xlwt

#主窗口
root = Tk()
root.geometry("600x500")
root.title("欢朋酒店房间号导出")

#查询窗口
en = Entry(root,width=52,bd=1)
en.place(x=120,y=55,height=31)

#查询函数
def requre(event=NONE):
    ipaddr = en.get()
    #判断IP格式是否正确
    try:
        if re.match(r"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ipaddr):
            db = pymysql.connect(ipaddr,"xiaoshuai","xshuai2015","tlkcs")
            cursor = db.cursor()
            cursor.execute("select rname,ipaddr,mac from h_rooms_conf")
            myresult = cursor.fetchall()
            for res in myresult:
                # print(res)
                show.insert('end',res)
                show.insert('end','\n')
        else:
            messagebox.showinfo(title="IP错误",message="IP地址格式错误，请重新输入！")
    except Exception as e:
            messagebox.showinfo(title="Error!",message=e)

#查询按钮
find_bt = Button(root,text='查找',bg='#0080FF',width=8,command=requre)
find_bt.place(x=480,y=55,height=31)

#导出按钮
def savefile():
    #创建excel表格
    excel = xlwt.Workbook()
    sheet = excel.add_sheet('Sheet1',cell_overwrite_ok=True)
    #设置表格属性及初始值
    sheet.col(0).width= 256*10
    sheet.col(1).width = 256*16
    sheet.col(2).width = 256*19
    sheet.write(0,0,'房间号')
    sheet.write(0,1,'IP')
    sheet.write(0,2,'MAC')
    #获取存储路径
    path = asksaveasfilename(initialfile='room_ip.xls')
    text=show.get('1.0',END).split('\n')
    text.pop()
    text.pop()
    for i in range(len(text)):
        str = text[i].split(' ')
        for j in range(3):
            sheet.write(i+1,j,str[j])
    excel.save(path)

Button(root,text='导出',bg='#0080FF',width=8,command=savefile).place(x=210,y=440,height=31)

#清空按键
def clear():
    show.delete(0.0,END)
Button(root,text='清空',bg='#0080FF',width=8,command=clear).place(x=410,y=440,height=31)


#结果展示窗口
show = Text(root,width=51,height=25)
show.place(x=120,y=110)

#键盘回车键绑定查询按键
root.bind("<Return>",requre)
root.mainloop()
