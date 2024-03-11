#导出数据库
mysqldump -hlx-prod-db.cxqj7gebrxbr.us-east-1.rds.amazonaws.com -P3306 -uwashboard -pkiosoft123wb?  laundry cbbt_app_trans > laundry_cbbt_app_trans.sql
mysqldump -hlx-prod-db.cxqj7gebrxbr.us-east-1.rds.amazonaws.com -P3306 -uwashboard -pkiosoft123wb? laundry cbbt_coin_collection > laundry_cbbt_coin_collection.sql
mysqldump -hlx-prod-db.cxqj7gebrxbr.us-east-1.rds.amazonaws.com -P3306 -uwashboard -pkiosoft123wb? laundry --ignore-table=laundry.cbbt_app_trans --ignore-table=laundry.cbbt_coin_collection > laundry.sql
mysqldump -hlx-prod-db.cxqj7gebrxbr.us-east-1.rds.amazonaws.com -P3306 -uwashboard -pkiosoft123wb? laundry_portal > laundry_portal.sql
mysqldump -hlx-prod-db.cxqj7gebrxbr.us-east-1.rds.amazonaws.com -P3306 -uwashboard -pkiosoft123wb? value_code > value_code.sql
mysqldump -hlx-prod-db.cxqj7gebrxbr.us-east-1.rds.amazonaws.com -P3306 -uwashboard -pkiosoft123wb? web_lcms > web_lcms.sql


#azure创建数据库
CREATE DATABASE `laundry` /*!40100 DEFAULT CHARACTER SET utf8 */
CREATE DATABASE `laundry_portal` /*!40100 DEFAULT CHARACTER SET utf8 */
CREATE DATABASE `value_code` /*!40100 DEFAULT CHARACTER SET utf8 */
CREATE DATABASE `web_lcms` /*!40100 DEFAULT CHARACTER SET utf8 */


#导入azure
mysql -hmariadb04-temp.mariadb.database.azure.com -ukiosoft -p123456 laundry < /tmp/sql/laundry-cbbt_app_trans.sql
mysql -hmariadb04-temp.mariadb.database.azure.com -ukiosoft -p123456 laundry < /tmp/sql/laundry-cbbt_coin_collection.sql
mysql -hmariadb04-temp.mariadb.database.azure.com -ukiosoft -p123456 laundry < /tmp/sql/laundry.sql
mysql -hmariadb04-temp.mariadb.database.azure.com -ukiosoft -p123456 laundry_portal < /tmp/sql/laundry_portal.sql
mysql -hmariadb04-temp.mariadb.database.azure.com -ukiosoft -p123456 value_code < /tmp/sql/value_code.sql
mysql -hmariadb04-temp.mariadb.database.azure.com -ukiosoft -p123456 web_lcms < /tmp/sql/web_lcms.sql