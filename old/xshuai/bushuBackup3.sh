#!/bin/bash
#功能：将备份任务及脚本部署到服务器
#用法：root用户下运行脚本

#检测是否为root用户
[ $UID -ne 0 ]&&echo "请切换成root身份执行此脚本"&&exit 1

#安装ftp
rpm -Uvh http://219.146.255.198:8098/share/software/ftp.rpm

#获取备份脚本
wget http://219.146.255.198:8098/share/zhang/scripts/backup3.sh -P /var/www/sh
chmod 777 /var/www/sh/backup3

#设置定时任务
echo "# 每月备份
00 03 01 * *      /bin/sh /var/www/sh/backup2.sh >/dev/null 2>&1
" >>/var/spool/cron/root

rm -rf bushuBackup.sh