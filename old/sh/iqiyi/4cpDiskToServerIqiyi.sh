#!/bin/bash
# 功能：硬盘向服务器拷贝（爱奇艺）
find /videos/ -type f | sort | while read line
do
        ###判断目录文件###
        if test -d ${line%/*} ;then
                if test -e $line ;then
			dstmd5=`md5sum $line | awk '{print $1}'`
			srcmd5=`md5sum $PWD/$line | awk '{print $1}'`
			if [ $dstmd5 == $srcmd5 ];then
				echo "[`date '+%Y-%m-%d_%H:%M:%S'`][iqiyi] $line md5 check correct,PASS!" >> /var/log/cpmovie.log
				#continue
			else
				echo "[`date '+%Y-%m-%d_%H:%M:%S'`][iqiyi] $line md5 check error,re-copy it" >> /var/log/cpmovie.log
               			cp -vf $PWD/$line $line
			fi
                else
                        echo "[`date '+%Y-%m-%d_%H:%M:%S'`][iqiyi] $line file not exist,dir exist,copy the file!" >> /var/log/cpmovie.log
                        cp -v $PWD/$line $line
                fi

        else
                echo "[`date '+%Y-%m-%d_%H:%M:%S'`][iqiyi] $line file not exist,mkdir dir and copy!" >> /var/log/cpmovie.log
                mkdir -p ${line%/*}
                cp -v $PWD/$line $line
        fi
done
