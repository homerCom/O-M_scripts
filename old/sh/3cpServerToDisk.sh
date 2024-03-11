#!/bin/bash
# 功能：从服务器往硬盘拷贝电影

mount_path=`pwd`

find /data/micro_ticket/dst/ -type f -name "*ts" | sort -k2n -r| while read line
do
        if test -d $mount_path${line%/*} ;then
                if test -e $mount_path$line ;then
                        echo "[`date '+%Y-%m-%d_%H:%M:%S'`] $mount_path$line file exist,PASS!" >> /var/log/cpServerToDisk.log
                        continue
                else
                        echo "[`date '+%Y-%m-%d_%H:%M:%S'`] $mount_path$line file not exist,dir exist,copy the file!" >> /var/log/cpServerToDisk.log
                        cp -v $line $mount_path$line
                fi
        else
                echo "[`date '+%Y-%m-%d_%H:%M:%S'`] $mount_path$line file not exist,mkdir dir and copy!" >> /var/log/cpServerToDisk.log
                mkdir -p $mount_path${line%/*}
                cp -v $line $mount_path$line
        fi
done
