#!/bin/bash
#每秒执行一次脚本名
#用法 脚本名 需要执行的脚本名 间隔的秒数

for((i=1;i<=60;i++));
do
bash $1
sleep $2
done
