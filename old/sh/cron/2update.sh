#!/bin/bash
# 更新小帅新程序

PATH=/bin:/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

localXsTempWar=`ls -t /home/hclient/war/*.war |  head -n1`
[ -z $localXsTempWar ]&&echo "no war exist"&&exit 1
localXsTempWarMd5=`md5sum $localXsTempWar | awk '{print $1}'`
remoteXsMd5=`curl -s http://127.0.0.1:4396/hclient/terminal/getSystemMd5`
XSLOG=/var/log/xs.log
LOCALXSWAR=/usr/local/xiaoshuai/tomcat/webapps/hclient.war

function now(){
        echo "[`date '+%Y-%m-%d %H:%M:%S'`]"
}

if [ $localXsTempWarMd5 == $remoteXsMd5 ];then
        echo "`now` The remote warbag is correct" >> $XSLOG
        if [ -f $LOCALXSWAR ];then
                localXsWarMd5=`md5sum $LOCALXSWAR | awk '{print $1}'`
                if [ $localXsWarMd5 == $remoteXsMd5 ];then
                        echo "`now` The corrent warbag is in the right state,exit" >> $XSLOG
                        exit 1
                else
                        echo "`now` update hclient warbag start" >> $XSLOG
                        service tomcat stop
                        cp -f $LOCALXSWAR ${LOCALXSWAR}.bak
                        cp -f $localXsTempWar $LOCALXSWAR
                        service tomcat start
                        echo "`now` update hclient warbag end" >> $XSLOG
                fi
        else
                echo "`now` install hclient warbag first time start" >> $XSLOG
                service tomcat stop
                cp -f $localXsTempWar $LOCALXSWAR
                service tomcat start
                echo "`now` install hclient warbag first time end" >> $XSLOG
        fi
else
        echo "`now` The remote warbag is not correct" >> $XSLOG
        exit 1
fi
