drop database stage_route_laundry;
drop database stage_route_laundry_portal;
drop database stage_route_value_code;
drop database stage_route_web_lcms;

CREATE DATABASE `stage_route_laundry` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
CREATE DATABASE `stage_route_laundry_portal` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
CREATE DATABASE `stage_route_value_code` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
CREATE DATABASE `stage_route_web_lcms` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;

UPDATE `stage_route_laundry_portal`.`api_keys` SET `key`='4kcocks4kskcc4s88448og8ww8ww88wgsgsc0wco' WHERE  `id`=1;