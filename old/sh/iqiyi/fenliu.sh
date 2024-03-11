#!/bin/bash
echo "1. 爱奇艺相关"
echo "爱奇艺版本："
head -13  /data/moviebar/moviebar.war | tail -n1
echo
mysql localplay -e  "select id,name,agent_code,auth_start_time,auth_end_time,cinema_num,auth_status from local_bar"
mysql localplay -e  "select count(*),playable from local_episode where online_status = 1 group by playable"
mysql localplay -e  "select type,p_value from local_property where p_key = 'ip'"
mysql localplay -e "select m3u8_url from local_episode where m3u8_url is not null limit 1"
echo "2.电影列表"
mysql localplay -e "select display_name,m3u8_url from local_episode where online_status=1 and playable=1;"
echo "3.下载时间"
mysql localplay -e "select p_key,p_value from local_property where type='property' and p_key like 'download%';"
echo "4.注册信息"
mysql -e "select cinema_num AS '授权数量' from localplay.local_bar"
mysql -e "select count(*) as '已注册' from localplay.local_device"
