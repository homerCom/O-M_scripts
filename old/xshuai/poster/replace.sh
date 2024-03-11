#!/bin/bash
#功能：将公共海报改名为没有海报的电影

for pic in `cat /var/www/share/zhang/scripts/poster/movie.txt`
do
	cp /var/www/share/zhang/scripts/poster/posters/public.jpg /var/www/sllcs/admin/images/movie/$pic.jpg
done
