#!/bin/bash
#lincolnzhang@techtrex.com

function read_dir(){
    for file in `ls $1`       	#遍历目录文件
    do
        if [ -d $1"/"$file ]  	#"-d" 判断是否目录
        then
            read_dir $1"/"$file	#遍历子目录
        else  
      
            echo ${file%.*}
            elasticdump --output=http://127.0.0.1:9200/${file%.*} --input=$1"/"$file --type=data
        fi
    done
} 
read_dir $1
