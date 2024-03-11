#!/bin/bash
#lincolnzhang@techtrex.com
start_date=`date -d "30 days ago" +%Y%m%d`        #开始日期
#######删除函数######
function delData(){
echo "$1$2" >> /back/elk/del_$2.log
curl  -XDELETE  "http://127.0.0.1:9200/$1$2" >> /dev/null 2>&1
}

indexs=(logstash-prod_amusement_nginx_access- logstash-prod_central_nginx_access- logstash-prod_cleanstore_nginx_access- logstash-prod_coffee_nginx_access- logstash-prod_ims_apache_access- logstash-prod_integration_nginx_access- logstash-prod_kps_backend_nginx_access- logstash-prod_latamcleanstore_nginx_access- logstash-prod_nginx_error- logstash-prod_route_als_nginx_access- logstash-prod_route_coinamatic_nginx_access- logstash-prod_route_fmb_nginx_access- logstash-prod_route_hercules_nginx_access- logstash-prod_universal_nginx_access- logstash-prod_website_kioplay_nginx_access- logstash-prod_website_kiosoft_nginx_access- logstash-prod_nginx_access- logstash-prod_waf_access- logstash-test_nginx_access- logstash-test_nginx_error- logstash-universal-waf- logstash-test_waf_access- logstash-test_nginx_access-)  #所有es需要删除的索引，会遍历这个数组去删除

  start_date=`date -d "+1 days ago ${start_date}" +%Y%m%d`                   #每循环一次，减一天时间(向前一天)
  startday=`date -d "$start_date" "+%Y.%m.%d"`     #转换时间格式
  for index in ${indexs[@]}                        #遍历索引
  do
    delData $index $startday                     #开始删除,第一个参数与第二个参数拼接成一个完整索引
  done
