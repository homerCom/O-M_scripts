#!/bin/bash
#lincolnzhang@techtrex.com
#######备份函数######
function exData(){
/usr/local/bin/elasticdump --input=http://127.0.0.1:9200/$1$2 --output=/back/elk/$2/$1$2.json --type=data --concurrency=10 --limit=10000 >> /dev/null 2>&1
    if [ $? -ne 0 ]; then                          #遇到错误记录
      echo $1$2 >> /back/elk/bak_error_$2.log        
    fi
}

indexs=(logstash-prod_amusement_nginx_access- logstash-prod_central_nginx_access- logstash-prod_cleanstore_nginx_access- logstash-prod_coffee_nginx_access- logstash-prod_ims_apache_access- logstash-prod_integration_nginx_access- logstash-prod_kps_backend_nginx_access- logstash-prod_latamcleanstore_nginx_access- logstash-prod_nginx_error- logstash-prod_universal_nginx_access- logstash-prod_website_kioplay_nginx_access- logstash-prod_website_kiosoft_nginx_access- logstash-prod_route_als_nginx_access- logstash-prod_route_coinamatic_nginx_access- logstash-prod_route_fmb_nginx_access- logstash-prod_route_hercules_nginx_access- logstash-prod_nginx_access- logstash-prod_waf_access- logstash-test_nginx_access- logstash-test_nginx_error- logstash-universal-waf- logstash-test_waf_access- logstash-test_nginx_access-)  #所有es需要备份的索引，会遍历这个数组去备份

  startday=`date -d "+1 days ago" +%Y.%m.%d`                 #前一天日期
  #echo $startday
  if [ ! -d /back/elk/$startday ]; then
  mkdir /back/elk/$startday                        #如果目录不存在创建目录
  fi
  for index in ${indexs[@]}                        #遍历索引
  do
    exData $index $startday 
  done

  cd /back/elk/
  tar zcf $startday.tar.gz ./$startday/*           #压缩备份文件
  rm -rf /back/elk/$startday/                      #删除压缩过的原文件
exit
