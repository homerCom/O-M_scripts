#!/bin/bash

mysql -ukiosoft -p123456 -e 'drop database stage_route_laundry'
mysql -ukiosoft -p123456 -e 'drop database stage_route_laundry_portal'
mysql -ukiosoft -p123456 -e 'drop database stage_route_value_code'
mysql -ukiosoft -p123456 -e 'drop database stage_route_web_lcms'

mysql -ukiosoft -p123456 -e 'CREATE DATABASE `stage_route_laundry` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -ukiosoft -p123456 -e 'CREATE DATABASE `stage_route_laundry_portal` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -ukiosoft -p123456 -e 'CREATE DATABASE `stage_route_value_code` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -ukiosoft -p123456 -e 'CREATE DATABASE `stage_route_web_lcms` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'

mysql -ukiosoft -p123456 stage_route_laundry < laundry.sql
mysql -ukiosoft -p123456 stage_route_laundry_portal < lp.sql
mysql -ukiosoft -p123456 stage_route_value_code < vc.sql
mysql -ukiosoft -p123456 stage_route_web_lcms < ccm.sql

mysql -ukiosoft -p123456 -e "UPDATE stage_route_laundry_portal.api_keys SET `key`='4kcocks4kskcc4s88448og8ww8ww88wgsgsc0wco' WHERE id=1"
