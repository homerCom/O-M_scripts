#!/bin/bash
'''
前提是表结构是存在的
注意自己的数据库是否区分大小写，以及表名称是否有大小写，如果表名称有大小写，新启动的mysql一定要开启大小写[开启大小写参数：lower_case_table_names = 0]
mysql_user变量的值为mysql数据目录的属主和属组
根据实际场景修改mysql_cmd变量的值，修改成自己用户名，用户密码，主机ip
mysql_data_dir变量的值为mysql数据存储路径
back_data_dir变量的值为备份下来的ibd文件存储路径
'''
base_dir=$(cd `dirname $0`; pwd)
mysql_user='mysql'
mysql_cmd="mysql -N -uroot -proot -h192.168.70.49"
databases_list=($(${mysql_cmd} -e 'SHOW DATABASES;' | egrep -v 'information_schema|mysql|performance_schema|sys'))
mysql_data_dir='/var/lib/mysql'
back_data_dir='/tmp/back-data'

for (( i=0; i<${#databases_list[@]}; i++ ))
do
  tables_list=($(${mysql_cmd} -e "SELECT table_name FROM information_schema.tables WHERE table_schema=\"${databases_list[i]}\";"))
  database_name=${databases_list[i]/-/@002d}

  for (( table=0; table<${#tables_list[@]}; table++ ))
  do
    ${mysql_cmd} -e "alter table \`${databases_list[i]}\`.${tables_list[table]} discard tablespace;"
    rm -f ${mysql_data_dir}/${database_name}/${tables_list[table]}.ibd
    cp ${back_data_dir}/${database_name}/${tables_list[table]}.ibd ${mysql_data_dir}/${database_name}/
    chown -R ${mysql_user}.${mysql_user} ${mysql_data_dir}/${database_name}/
    ${mysql_cmd} -e "alter table \`${databases_list[i]}\`.${tables_list[table]} import tablespace;"
    sleep 5
  done
done


'''
通过shell脚本导出mysql所有库的所有表的表结构
mysql_cmd和dump_cmd的变量值根据实际环境修改，修改成自己用户名，用户密码，主机ip
databases_list只排除了mysql的系统库，如果需要排除其他库，可以修改egrep -v后面的值
导出的表结构以库名来命名，并且加入了CREATE DATABASE IF NOT EXISTS语句
'''
#!/bin/bash
base_dir=$(cd `dirname $0`; pwd)
mysql_cmd="mysql -N -uroot -proot -h192.168.70.49"
dump_cmd="mysqldump -uroot -proot -h192.168.70.49"
databases_list=($(${mysql_cmd} -e 'SHOW DATABASES;' | egrep -v 'information_schema|mysql|performance_schema|sys'))

for (( i=0; i<${#databases_list[@]}; i++ ))
do
  tables_list=($(${mysql_cmd} -e "SELECT table_name FROM information_schema.tables WHERE table_schema=\"${databases_list[i]}\";"))

  [[ ! -f "${base_dir}/${databases_list[i]}.sql" ]] || rm -f ${base_dir}/${databases_list[i]}.sql
  echo "CREATE DATABASE IF NOT EXISTS \`${databases_list[i]}\`;" >> ${base_dir}/${databases_list[i]}.sql
  echo "USE \`${databases_list[i]}\`;" >> ${base_dir}/${databases_list[i]}.sql

  for (( table=0; table<${#tables_list[@]}; table++ ))
  do
    ${dump_cmd} -d ${databases_list[i]} ${tables_list[table]} >> ${base_dir}/${databases_list[i]}.sql
  done
done