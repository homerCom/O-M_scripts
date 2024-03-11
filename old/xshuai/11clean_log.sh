#!/bin/bash
# 功能：清理日志文件
# 用法：直接运行脚本

logname=`/bin/hostname`-slow.log

echo '' > /data/mysql/$logname
echo '' > /var/log/access.log
echo '' > /data/html/micro/Application/Runtime/Logs/videoBoxDaemonRolling.log
echo '' > /opt/micro/Application/Runtime/Logs/videoBoxDaemonRolling.log
