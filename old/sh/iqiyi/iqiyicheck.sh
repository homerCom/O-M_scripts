#!/bin/bash
# 功能：检测爱奇艺

xsVpn=`ifconfig | awk '/10\.8./{print $2}'|awk -F ':' '{print $2}'`
echo
echo "0. 云端酒店信息"
#mysql -h 10.8.0.206 -uroot -p -e "use manage;select id,hotelName,hotel,ipaddr,hzid from h_hotels where ipaddr like \"%$xsVpn%\""
echo
echo "1. d_config（华住项目注意看是否有hz_hotel_id）"
mysql tlkcs -e "select * from d_config where name in ('default_server','localVpnip','projectName','hotel_id','hotel_username','telckey','hz_hotel_id');"
echo
echo "2. launcher配置"
mysql tlkcs -e "SELECT mf.morder,mf.mname,mf.attr,mf.bljlm,ma.name as attrName FROM h_menu mf left join h_menuattr ma on mf.attr=ma.attr WHERE mf.pid=0 and (mf.attr=1 or mf.attr=99 ) order by mf.morder;"
echo
echo "2.5 目录配置"
mysql tlkcs -e "select m.morder,l.content from h_language l left join h_menu m on l.mid=m.id where l.type in (1,2) and m.attr in (1,99) and m.pid=0 order by m.morder,l.type; "
echo
echo "3. apk配置"
mysql tlkcs -e "select a.id,a.apk_name,apk_package,f.platform_name,a.md5 from h_apk a left join h_apk_platform f on a.apk_platform=f.platform_num order by f.platform_name,apk_package;"
echo
echo "4. 服务配置(apkName：爱奇艺电视，version：99)"
mysql tlkcs -e "SELECT id,apkName,serviceName,version FROM h_service_list WHERE 1"
echo
echo "5. 下载配置"
mysql tlkcs -e "select id,music_name,music_addr,state,md5 from h_music;"
echo
echo "6. 版本控制（至少一个版本）"
mysql tlkcs -e "select id,uname,intro,dataVersion,module,roomStr,stime from h_update_version;"
echo
echo "7. 参数设置（检查电影IP地址）"
mysql tlkcs -e "select * from h_canshu where name in ('电影IP地址','酒店留言滚动');"
echo
echo "8. 天气设置"
/usr/local/travelink/php/bin/php /var/www/tlkcs/onlineweather.php
echo
echo "9. 爱奇艺相关"
echo "爱奇艺版本："
head -13  /data/moviebar/moviebar.war | tail -n1 
echo
mysql localplay -e  "select id,name,agent_code,auth_start_time,auth_end_time,cinema_num,auth_status from local_bar"
mysql localplay -e  "select count(*),playable from local_episode where online_status = 1 group by playable"
mysql localplay -e  "select type,p_value from local_property where p_key = 'ip'"
echo
echo "10. 本地设备信息_xiaoshuai"
mysql tlkcs -e "select r.*,a.platform_name from h_rooms_conf r left join h_apk_platform a on r.platform=a.platform order by r.rname;"
mysql tlkcs -e "select count(rname),r.platform,a.platform_name from h_rooms_conf r left join h_apk_platform a on r.platform=a.platform group by r.platform;"
echo "11.本地设备信息_iqiyi"
mysql localplay -e "select cinema_code,device_code,device_id from local_device;"
echo "12.电影列表(电影IP地址是否正确)"
mysql localplay -e "select display_name,m3u8_url from local_episode where online_status=1 and playable=1;"
mysql localplay -e "select count(display_name) from local_episode where online_status=1 and playable=1;"
echo "13.下载时间（0点到10点）"
mysql localplay -e "select p_key,p_value from local_property where type='property' and p_key like 'download%';"
echo "14.注册信息"
mysql -e "select cinema_num AS '授权数量' from localplay.local_bar"
mysql -e "select count(*) as '已注册' from localplay.local_device"
