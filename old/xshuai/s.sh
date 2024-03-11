/usr/sbin/dhclient
rpm -qa|grep -q wget
[ $? -eq 1 ]&&yum install -y wget

ping 114.114.114.114 -w 3 >/dev/null
if [ $? -eq 0 ];then
	rm -rf /opt/ftxDocker1421.sh
	wget -q -P /opt/ http://update.xshuai.com:8098/share/zhang/scripts/ftxDocker1421.sh
fi

bash /opt/ftxDocker1421.sh
