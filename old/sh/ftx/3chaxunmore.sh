#!/bin/bash
# 功能：删除风霆迅服务器上多余的电影
user=root
pass=123456
if [ ! -d /opt ];then
	mkdir /opt
fi
find /data/micro_ticket/dst/ -name "*.ts"  > /opt/bendi_all.txt
if [ $? -ne 0 ];then
	echo "错误退出find"
	exit
fi
mysql -u$user -p$pass -S /dev/shm/mysql.sock -e "use mictic;select concat(file_path,save_name) from mt_video where xs_video = 1 and down_status in (1,2) and status=1;" > /opt/xuyao_baoliu.txt
if [ $? -ne 0 ];then
	echo "错误退出mysql"
	exit
fi
sed -i '/concat/d' /opt/xuyao_baoliu.txt
if [ -f /opt/shanchu_list.txt ];then
	rm /opt/shanchu_list.txt -rf
fi
cat /opt/bendi_all.txt | while read line
do
        ts=`echo $line | awk -F/ '{print $NF}'`
        num=`grep $ts /opt/xuyao_baoliu.txt | wc -l`
        if [ $num -eq 0 ];then
                echo $line >> /opt/shanchu_list.txt
        fi
done
num_bendi_ts=`cat  /opt/bendi_all.txt |wc -l`
num_baoliu_ts=`cat  /opt/xuyao_baoliu.txt | wc -l`
num_shanchu=`cat /opt/shanchu_list.txt |wc -l`
echo "服务器现有ts数量:  $num_bendi_ts"
echo "服务器要保留的ts数量:  $num_baoliu_ts"
echo "要删除的目标ts数量:  $num_shanchu"
echo "     "
echo "请务必注意:确认一下删除的目标文件是否有误，再执行 cat /opt/shanchu_list.txt | xargs rm -rfv"
