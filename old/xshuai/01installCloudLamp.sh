#!/bin/bash
# 功能：在Ubuntu上安装LAMP + SAMBA + 其他 + 系统安装时间记录
# 平台：ubuntu 12.04 64位
# 格式：脚本名 用户名

username=$1
dbpasswd=$username
[ $UID -ne 0 ]&&echo "Run this shell script with the user root.(sudo -s)"&&exit 1
[ $# -ne 1 ]&&echo "Please input the parameter after the script name!"&&exit 1
[ ! -d /home/$username/ ]&&echo "The user you added seems not to be $username,change it please!"&&exit 1

uname -i | grep -q x86_64
[ $? -ne 0 ]&&echo "your system is not 64bit!"&&exit 1
cat /etc/issue | grep -q 12.04
[ $? -ne 0 ]&&echo "your ubuntu version is not 12.04!"&&exit 1

# 检查网络
echo "Checking the network..."
ping www.163.com -c 2 2>/dev/null
[ $? -ne 0 ]&&echo "Can't Ping To www.163.com,Check The Network Configuration Please"&&exit 1
printf "%-60s%s\n" "Network" "[OK]" 

# 开启cron日志
sed -i '/#cron/s/#//g' /etc/rsyslog.d/50-default.conf
service rsyslog restart

# 安装软件
chmod -R 777 *
echo "Start To install E-HOTEL Environment....."
apt-get update
echo "start to install vim"
apt-get install vim -y
printf "%-60s%s\n" "vim" "[OK]" 
echo "start to install openvpn"
apt-get install openvpn -y
printf "%-60s%s\n" "openvpn" "[OK]" 
echo "start to install nmap"
apt-get install nmap -y
printf "%-60s%s\n" "nmap" "[OK]" 
echo "start to install ssh"
apt-get install openssh-server -y
printf "%-60s%s\n" "ssh" "[OK]" 
echo "start to install dpkg-dev"
apt-get install dpkg-dev -y
printf "%-60s%s\n" "dpkg-dev" "[OK]" 
echo "start to install axel"
apt-get install axel -y
printf "%-60s%s\n" "axel" "[OK]" 
echo "start to install iftop"
apt-get install iftop -y
printf "%-60s%s\n" "iftop" "[OK]" 
echo "start to install dos2unix"
apt-get install dos2unix -y
printf "%-60s%s\n" "dos2unix" "[OK]" 
echo "start to install curl"
apt-get install curl -y
printf "%-60s%s\n" "curl" "[OK]" 
echo "start to install apache"
apt-get install apache2 -y
sed -i "s/None/All/g" /etc/apache2/sites-available/default
printf "%-60s%s\n" "apache" "[OK]" 
echo "start to install samba"
[ ! -d /home/$username/share/ ]&&mkdir -v /home/$username/share/
chmod -R 777 /home/$username/share
ln -s /home/$username/share /var/www/share
echo "start to install mysql"
echo mysql-server mysql-server/root_password password $dbpasswd | debconf-set-selections
echo mysql-server mysql-server/root_password_again password $dbpasswd | debconf-set-selections
apt-get install mysql-server -y
printf "%-60s%s\n" "MySQL" "[OK]" 
echo "start to install PHP"
apt-get install php5 php5-mysql php5-curl php5-gd libapache2-mod-php5 libapache2-mod-auth-mysql -y
a2enmod rewrite php5
printf "%-60s%s\n" "PHP" "[OK]" 
service apache2 restart

# 其他设置
# other info
timeNow=`date "+%Y-%m-%d %H:%M:%S"`
echo "starttime:"$timeNow>/var/www/hotelinfo.txt
echo "The E-HOTEL Environment is installed"
rm $0
