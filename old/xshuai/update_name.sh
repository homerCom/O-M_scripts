#!/bin/bash
#作用：后台名
#用法：脚本名 后台名 后台名称
htname=$1
name=$2
mysql -uroot -p123456 <<EOF
		use $htname;
		update d_config set config='$name' where name="hotel_username";
EOF