#!/bin/bash

MYSQL_USER=${MYSQL_USER:-reseller}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-`openssl rand -base64 16`}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-`openssl rand -base64 16`}

mysql --user="root" --password="${MYSQL_ROOT_PASSWORD}" --host="${MYSQL_HOST:-localhost}" --port="${MYSQL_PORT:-3306}" <<EOF
SET FOREIGN_KEY_CHECKS=0;                                                                                                                                                    
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";
CREATE DATABASE IF NOT EXISTS whmcs CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON whmcs.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON wordpress.* TO '${MYSQL_USER}'@'%';                           
COMMIT;
EOF
