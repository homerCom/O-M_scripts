#!/bin/bash
# 功能：从服务器往硬盘拷贝电影（爱奇艺）
# 把移动硬盘放到移动硬盘里执行

find /iqiyidisk/ -type f | sort | while read line
do
        ###判断目录文件###
        if test -d $PWD/${line%/*} ;then	# 判断目录
                if test -e $PWD/$line ;then	# 判断文件
                        dstmd5=`md5sum $PWD/$line | awk '{print $1}'`
                        srcmd5=`md5sum $line | awk '{print $1}'`
                        if [ $dstmd5 == $srcmd5 ];then
                                echo "[`date '+%Y-%m-%d_%H:%M:%S'`][iqiyi] $line md5 check correct,PASS!" >> /var/log/cpServerToDisk.log
                                #continue
                        else
                                echo "[`date '+%Y-%m-%d_%H:%M:%S'`][iqiyi] $line md5 check error,re-copy it" >> /var/log/cpServerToDisk.log
                                cp -vf $line $PWD/$line
                        fi
                else
                        echo "[`date '+%Y-%m-%d_%H:%M:%S'`][iqiyi] $line file not exist,dir exist,copy the file!" >> /var/log/cpServerToDisk.log
                        cp -v $line $PWD/$line
                fi

        else
                echo "[`date '+%Y-%m-%d_%H:%M:%S'`][iqiyi] $line file not exist,mkdir dir and copy!" >> /var/log/cpServerToDisk.log
                mkdir -p $PWD/${line%/*}
                cp -v $line $PWD/$line
        fi
done
