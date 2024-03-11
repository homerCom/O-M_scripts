#!/bin/bash
# 上传数据
PATH=/bin:/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

ls /var/www/ | grep cs$ | while read houtai
do
	if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
		/usr/bin/curl http://127.0.0.1:8000/tlkcs/port/hzzc
	else
		/usr/bin/curl http://127.0.0.1/tlkcs/port/hzzc
	fi
done
