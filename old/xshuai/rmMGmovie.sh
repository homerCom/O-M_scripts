#!/bin/bash

find /video/micro_ticket/dst/ -type d > /opt/movies.txt
rm -rf /opt/mg_movies.txt
cat /opt/movies.txt | while read line
do
	doc=`basename $line`
	len=`echo $doc | awk '{print length($0)}'`
	#echo $len
	if [ $len = '32' ];then
        	echo $line >> /opt/mg_movies.txt
	fi
done
count=`cat /opt/mg_movies.txt | wc -l`
echo "共找到芒果电影：$count"
echo "电影删除后不可恢复，请仔细确认之后再执行：cat /opt/mg_movies.txt | xargs rm -rfv"
