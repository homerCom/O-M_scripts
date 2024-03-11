#!/bin/bash


wget -P /root/ http://219.146.255.198:8098/share/zhang/softwares/1Public/mbm_V2.0.apk
wget -P /root http://219.146.255.198:8098/share/zhang/files/addVersion.php.1
mv /root/addVersion.php.1 /root/addVersion.php
ls /var/www|grep 'cs$'|while read line
do	
	dbUser=`awk -F "'" '/DB_USER/{print $4}' /var/www/$line/config.php`
    dbPassword=`awk -F "'" '/DB_PWD/{print $4}' /var/www/$line/config.php`
	cp /root/addVersion.php /var/www/$line/
	cat /var/www/$line/admin/template/admin/login.html | grep -q 8888
        if [ $? -eq 0 ];then
                cp /root/mbm_V2.0.apk /var/www/share/hvupdate/
                mysql -u$dbUser -p$dbPassword $line -e 'insert into h_apk (apk_code,apk_name,apk_package,apk_platform) values (1,"mbm_V2.0.apk","com.dfzt.tvlauncher",0)'
				mysql -u$dbUser -p$dbPassword $line -e 'update h_menu set mname="音乐欣赏",bljlm="com.dfzt.tvlauncher" where bljlm="com.tencent.qqmusictv"'
				mysql -u$dbUser -p$dbPassword $line -e 'update h_modules set update_ver = update_ver+1 where module_name="menu"'
        else
                cp /root/mbm_V2.0.apk /var/www/$line/admin/images/apk/
                mysql -u$dbUser -p$dbPassword $line -e 'insert into h_apk (apk_code,apk_name,apk_package,apk_platform,md5) values (1,"images/apk/mbm_V2.0.apk","com.dfzt.tvlauncher",0,"677f693da5f2acc342888d03ddbffbdb")'
		mysql -u$dbUser -p$dbPassword $line -e 'update h_menu set mname="音乐欣赏",bljlm="com.dfzt.tvlauncher" where bljlm="com.tencent.qqmusictv"'
        fi
	mysql -u$dbUser -p$dbPassword $line -e 'delete from h_apk where apk_package="com.tencent.qqmusictv"'
	mysql -u$dbUser -p$dbPassword $line -e 'delete from h_apk where apk_package="st.com.xiami"'
done
rm -rfv /root/mbm_V2.0.apk
rm -rvf $0
ls /var/www|grep 'cs$'
