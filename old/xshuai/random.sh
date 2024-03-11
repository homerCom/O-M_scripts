#!/bin/bash
#功能：取输入区间中的随机数
#用法：脚本名 开始数字  结束数字

[ $# -ne 2 ] && echo "参数错误，请输入两个参数：" && exit
function rand(){
	min=$1
	max=$(($2-$1+1))
	num=$(date +%s%N)
	echo $(($num%$max+$min))
}

echo $(rand $1 $2)
