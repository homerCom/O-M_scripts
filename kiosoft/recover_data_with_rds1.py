#!/usr/bin/env python
# -*- coding: UTF-8 -*-

# @Time    : 2023-03-13
# @Author  : Bale

import struct
from socket import *

BASE_DIR = "/KiosoftApplications/ServerApps/TTI_ReportServer/logs/"
#DISPOSE_LOG = ["2023-02-20","2022-02-21"]
DISPOSE_LOG = "2023-02-05,2023-03-09"
REPORT_SERVER_HOST = "127.0.0.1"
REPORT_SERVER_PORT = 5005

# read log
def read_log(filename):
    res = []
    fileHandle = open(filename, "r")
    while True:
        lineInfo = fileHandle.readline()
        if not lineInfo:
            break
        lineInfo = lineInfo.replace("\n","")
        if lineInfo == "":
            continue
        if lineInfo.find("packet content:") != -1:
            package = lineInfo.split("packet content:")[1]
            print(package)
            res.append(package)

    return res

# send data
def send_data(package):
    tcp_socket = socket(AF_INET , SOCK_STREAM)
    tcp_socket.connect((REPORT_SERVER_HOST, REPORT_SERVER_PORT))
    data = ''.join([chr(i) for i in [int(b, 16) for b in package.split(' ')]])
    tcp_socket.send(struct.pack("%sB" % (len(data),), *[ord(i) for i in data]))
    recv_data = tcp_socket.recv(1024)
    print(recv_data)
    tcp_socket.close()

if __name__ == '__main__':
    import datetime
    days = []
    if isinstance(DISPOSE_LOG, str):
        dayInterval = DISPOSE_LOG.split(',')
        dayStart = dayInterval[0]
        dayEnd = dayInterval[1]
        while dayStart <= dayEnd:
            days.append(dayStart)
            dayStart = datetime.datetime.strftime(datetime.datetime.strptime(dayStart,"%Y-%m-%d")+datetime.timedelta(days=1),"%Y-%m-%d")
    elif isinstance(DISPOSE_LOG, list):
        days = DISPOSE_LOG
    for f in days:
        filename = BASE_DIR + "tti_rs.log." + f
        print(filename)
        cmds = read_log(filename)
        for packItem in cmds:
            send_data(packItem)
