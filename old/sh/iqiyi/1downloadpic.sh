#!/bin/bash
# 爱奇艺轮播图
mysql -h 120.26.71.181 -uroot -p manage -e "SELECT pic from h_movies_iqiyi_focus where stime in(select substring_index(group_concat(stime order by stime desc),',',1) as maxid from h_movies_iqiyi_focus group by addr) group by addr" | sed 1d | while read line
do
        wget http://120.26.71.181/manage/$line -O /var/www/tlkcs/admin/$line
done

#下面两张图
mysql -h 120.26.71.181 -uroot -p manage -e "SELECT pic FROM  h_movies_iqiyi_topads;" | sed 1d | while read line
do
        wget http://120.26.71.181/manage/$line -O /var/www/tlkcs/admin/$line
done
echo "done"
