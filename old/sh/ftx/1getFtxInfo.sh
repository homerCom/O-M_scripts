#!/bin/bash
# 功能：检测爱奇艺

xsVpn=`ifconfig | awk '/10\.8./{print $2}'|awk -F ':' '{print $2}'`
echo
echo "0. 云端酒店信息"
mysql -uroot -p123456 -h 120.26.71.181 -uroot -ptravelink -e "use manage;select id,hotelName,hotel,ipaddr,hzid from h_hotels where ipaddr like \"%$xsVpn%\""
echo
echo "1. d_config（华住项目注意看是否有hz_hotel_id）"
mysql -uroot -p123456 tlkcs -e "select * from d_config where name in ('default_server','localVpnip','projectName','hotel_id','hotel_username','telckey','hz_hotel_id');"
echo
echo "2. launcher配置"
mysql -uroot -p123456 tlkcs -e "select m.morder AS '一级排序',m.mname AS '一级目录',m.attr AS '属性',n.morder AS '二级排序',n.mname AS '二级目录',n.attr AS '属性',n.bljlm AS '包名' from h_menu m left join h_menu n on m.id=n.pid where m.attr=1 UNION select m.morder AS '排序',m.mname AS '一级目录',m.attr AS '属性',n.morder AS '二级排序',n.mname AS '二级目录',n.attr AS '属性',n.bljlm AS '包名' from h_moviemenu m left join h_moviemenu n on m.id=n.pid where n.attr=11 or n.attr=99 order by 一级排序,二级排序;"
echo
echo "3. apk配置"
cat /var/www/tlkcs/admin/template/admin/login.html | grep -q 8888
if [ $? -eq 0 ];then
	mysql -uroot -p123456 tlkcs -e "select a.id,a.apk_code,a.apk_name,apk_package,f.platform_name from h_apk a left join h_apk_platform f on a.apk_platform=f.platform_num order by f.platform_name,apk_package;"
else
	mysql -uroot -p123456 tlkcs -e "select a.id,a.apk_name,apk_package,f.platform_name,a.md5 from h_apk a left join h_apk_platform f on a.apk_platform=f.platform_num order by f.platform_name,apk_package;"
fi
echo
echo "4. 服务配置"
mysql -uroot -p123456 tlkcs -e "SELECT id,apkName,serviceName,version FROM h_service_list WHERE 1"
echo
echo "5. 下载配置"
cat /var/www/tlkcs/admin/template/admin/login.html | grep -q 8888
if [ $? -eq 0 ];then
	mysql -uroot -p123456 tlkcs -e "select id,music_name,music_addr,state from h_music;"
else
	mysql -uroot -p123456 tlkcs -e "select id,music_name,music_addr,state,md5 from h_music;"
fi
echo
echo "6. 版本控制"
cat /var/www/tlkcs/admin/template/admin/login.html | grep -q 8888
if [ $? -ne 0 ];then
	mysql -uroot -p123456 tlkcs -e "select id,uname,intro,dataVersion,module,roomStr,stime from h_update_version;"
fi
echo
echo "7. 参数设置"
mysql -uroot -p123456 tlkcs -e "select * from h_canshu where name in ('电影IP地址','酒店留言滚动');"
echo
echo "8. 天气设置"
/usr/local/travelink/php/bin/php /var/www/tlkcs/onlineweather.php
echo
echo "9. 本地设备信息"
cat /var/www/tlkcs/admin/template/admin/login.html | grep -q 8888
if [ $? -ne 0 ];then
	mysql -uroot -p123456 tlkcs -e "select r.*,a.platform_name from h_rooms_conf r left join h_apk_platform a on r.platform=a.platform order by r.rname;"
	mysql -uroot -p123456 tlkcs -e "select count(rname),r.platform,a.platform_name from h_rooms_conf r left join h_apk_platform a on r.platform=a.platform group by r.platform;"
fi
echo
echo "10. 风霆迅系统版本"
curl http://127.0.0.1/Organ/Cron/getInfo
echo
echo
echo "11.小帅后台版本："
ls /var/www/ | grep cs$ | while read houtai
do
        echo $houtai
        grep -q 8888 /var/www/$houtai/admin/template/admin/login.html
        [ $? -eq 0 ]&&echo "2.0"||echo "3.0"
done
echo
echo "12. 相关接口"
echo "http://127.0.0.1:8000/tlkcs/port/getlocalVpnip 返回："
curl http://127.0.0.1:8000/tlkcs/port/getlocalVpnip
echo
