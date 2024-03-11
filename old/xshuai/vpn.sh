mysql -uroot -phappyview vpn -e "TRUNCATE TABLE  vpn_list"
ls /var/www/share/10.8段key/|while read line
do 
vpn=`echo $line|awk -F "@" '{print $1}'`
name=`echo $line|awk -F "@" '{print $2}'`
num=`echo $line|awk -F "@" '{print $3}'`

if [ $name ];then
	echo $line >> vpnNew.txt
		mysql -uroot -phappyview vpn -e "insert into vpn_list(vpn,name,num ) values('$vpn','$name','$num')"
fi
done
