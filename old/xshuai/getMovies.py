#!/usr/bin/python3

import subprocess
import platform

def getResult( cmd ):
	result = subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
	movies = result.stdout.read().decode("utf8", "idownload_gnore").replace('|','').strip()
	return movies

if __name__ == '__main__':
	result = subprocess.run('docker ps',shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,encoding="utf-8",timeout=1)
	if result.returncode == 0:
		all_cmd = 'docker exec -it ftxjoy mysql -S /dev/shm/mysql.sock -uroot -p123456 -N -e "use mictic;select count(*) from mt_video where xs_video=1"| sed -n "3p"'
		all_movies = getResult(all_cmd)
		download_cmd = 'docker exec -it ftxjoy mysql -S /dev/shm/mysql.sock -uroot -p123456 -N -e "use mictic;select count(*) from mt_video_info where down_status=2 and id in (select id from mt_video where xs_video=1)"| sed -n "3p"'
		download_movies = getResult(download_cmd)
		downloading_cmd = 'docker exec -it ftxjoy mysql -S /dev/shm/mysql.sock -uroot -p123456 -N -e "use mictic;select count(*) from mt_video_info where down_status=1 and id in (select id from mt_video where xs_video=1)"| sed -n "3p"'
		downloading_movies = getResult(downloading_cmd)	
		#启动aria下载程序
		subprocess.run('docker exec -i ftxjoy /usr/bin/aria2c --conf-path=/etc/aria2c.conf -D',shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,encoding="utf-8",timeout=1)
	else:	
		all_cmd = 'mysql -uroot -p123456 -N -e "use mictic;select count(*) from mt_video where xs_video=1"| sed 2d'
		all_movies = getResult(all_cmd)
		download_cmd = 'mysql -uroot -p123456 -N -e "use mictic;select count(*) from mt_video_info where down_status=2 and id in (select id from mt_video where xs_video=1)"| sed 2d'
		download_movies = getResult(download_cmd)
		downloading_cmd = 'mysql -uroot -p123456 -N -e "use mictic;select count(*) from mt_video_info where down_status=1 and id in (select id from mt_video where xs_video=1)"| sed 2d'
		downloading_movies = getResult(downloading_cmd)	
		#启动aria下载程序
		subprocess.run('/usr/bin/aria2c --conf-path=/etc/aria2c.conf -D',shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,encoding="utf-8",timeout=1)
	print("全部电影：%s"%all_movies)
	print("已下载：%s"%download_movies)
	print("下载中：%s"%downloading_movies)
