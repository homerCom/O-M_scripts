#!/bin/bash
#功能：批量添加用户

stty -echo 
read -e -p "请输入密码：" PASSWD
stty echo
for username in `cat $PWD/user.txt`
do
	useradd $username &> /dev/null
	if [ $? -ne 0 ];then
		echo "$username is exists!"
	else 
		echo $username:$PASSWD|chpasswd
		echo "$username create success!"
		
	fi
done
