#!/bin/bash
echo -n "操作系统信息:"
[ -f /etc/redhat-release ]&&cat /etc/redhat-release||cat /etc/issue

if [ -f /etc/redhat-release ];then
        cat /etc/redhat-release | grep -q 6.6
	if [ $? -eq 0 ];then
		echo -e "分类：\t风霆迅主机"
		echo -n "风霆迅版本："
		curl http://127.0.0.1/Organ/Cron/getInfo	
	fi
        cat /etc/redhat-release | grep -q 6.7 && echo "爱奇艺主机"
        cat /etc/redhat-release | grep -q 7.3 && echo "小帅主机"
else
        cat /etc/issue | grep -q 12.04
	if [ $? -eq 0 ];then
                echo -e "分类：\tubuntu主机"
                echo -n "风霆迅版本："
                curl http://127.0.0.1:20080/Organ/Cron/getInfo
        fi
fi
echo
ls /var/www/ | grep cs$ | while read houtai
do
	dbUser=`awk -F "'" '/DB_USER/{print $4}' /var/www/$houtai/config.php`
	dbPwd=`awk -F "'" '/DB_PWD/{print $4}' /var/www/$houtai/config.php`

	# 2.0 3.0
	echo
	echo "d_config 信息"
	mysql -u$dbUser -p$dbPwd $houtai -e "select * from d_config where name in ('default_server','localVpnip','projectName','hotel_id','hotel_username','telckey','hz_hotel_id');"
	echo
        # 2.0
        grep -q 8888 /var/www/$houtai/admin/template/admin/login.html
        if [ $? -eq 0 ];then
                echo -e "小帅后台版本：\t$houtai 2.0"
		echo
		echo "$houtai 目录结构"
		mysql -u$dbUser -p$dbPwd $houtai -e "select m.morder AS '一级排序',m.mname AS '一级目录',m.attr AS '属性',n.morder AS '二级排序',n.mname AS '二级目录',n.attr AS '属性',n.bljlm AS '包名' from h_menu m left join h_menu n on m.id=n.pid where m.attr=1 UNION select m.morder AS '排序',m.mname AS '一级目录',m.attr AS '属性',n.morder AS '二级排序',n.mname AS '二级目录',n.attr AS '属性',n.bljlm AS '包名' from h_moviemenu m left join h_moviemenu n on m.id=n.pid where n.attr=11 or n.attr=99 order by 一级排序,二级排序;"
        # 3.0
        else
                echo -e "小帅后台版本：\t$houtai 3.0"
		echo
		echo "$houtai 目录结构"
		mysql -u$dbUser -p$dbPwd $houtai -e "SELECT mf.morder,mf.mname,mf.attr,mf.bljlm,ma.name as attrName FROM h_menu mf left join h_menuattr ma on mf.attr=ma.attr WHERE mf.pid=0 and (mf.attr=1 or mf.attr=99 ) order by mf.morder;"
        fi
	
	# apk
	echo "$houtai apk"
	mysql -u$dbUser -p$dbPwd $houtai -e "select a.id,a.apk_code,a.apk_name,apk_package,f.platform_name from h_apk a left join h_apk_platform f on a.apk_platform=f.platform_num order by f.platform_name,apk_package;"
        echo
done
