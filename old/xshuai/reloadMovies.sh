#!/bin/bash

mysql -uroot -p123456 -S /dev/shm/mysql.sock -e "use mictic;delete from mt_video; delete from mt_video_info"
cd /data/html/micro && /usr/local/m1905/php/bin/php index.php /Home/Common/updateCinemaHostInfo
cd /data/html/micro && /usr/local/m1905/php/bin/php index.php /Home/Common/updateCloudVideo
cd /data/html/micro && /usr/local/m1905/php/bin/php index.php /Home/Common/scanDiskVideo
