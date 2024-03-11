#!/bin/bash
read -e -p "请输入新后台名：" name
mysql -uroot -p123456 << EOF
		use tlkcs;
		update d_config set config="$name" where name="hotel_username";
EOF