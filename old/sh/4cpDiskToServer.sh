#!/bin/bash
# 功能：硬盘向服务器拷贝
# 注意：脚本需与源目录data在同一目录下，源目录路径必须是/data/micro_ticket/dst/.. 

mount_path=`pwd`
if [ ! -L /data/micro_ticket ];then
	mkdir /data/ /video/micro_ticket
	ln -s /video/micro_ticket /data/micro_ticket
fi

find $mount_path/data/micro_ticket/dst/ -type f -name "*ts" -size +0 | sort -k2n -r| awk -F "$mount_path" '{print $2}' | while read line
do
        ###判断目录文件###
        if test -d ${line%/*} ;then
                if test -e $line ;then
                        echo "[`date '+%Y-%m-%d_%H:%M:%S'`] $line file exist,PASS!" >> /var/log/cpmovie.log
                        continue
                else
                        echo "[`date '+%Y-%m-%d_%H:%M:%S'`] $line file not exist,dir exist,copy the file!" >> /var/log/cpmovie.log
                        cp -v $mount_path$line $line
                fi

        else
                echo "[`date '+%Y-%m-%d_%H:%M:%S'`] $line file not exist,mkdir dir and copy!" >> /var/log/cpmovie.log
                mkdir -p ${line%/*}
                \cp -v $mount_path$line $line
        fi
done
