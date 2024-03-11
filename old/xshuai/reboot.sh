#!/bin/bash
#功能：ADB重启所有安卓终端

for ((i=100;i<102;i++))
do
	adb kill-server
	adb connect 192.168.1.$i >> ./reboot.log
	sleep 5
	adb reboot &
done
