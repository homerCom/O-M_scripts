#!/bin/bash
#更新列表中的数据库
for database in `cat /home/scripts/database`
do
	mysql -uroot -p101419 << EOF
		use $database;
		delete FROM d_collect_apk WHERE room not in (select rname from h_rooms);
		update  d_collect_apk set state=1 WHERE 1;
EOF
done
