# WHMCS + Wordpress run using docker #

* [Introduction](#introduction)
* [Docker Service](#docker-service)
* [Docker Environment Variable](#docker-environment-variable)
* [Docker Volume](#docker-volume)
* [Unsupported Feature](#unsupported-feature)

## Introduction ##
Provide base structure to run both whmcs and wordpress for marketing using docker and docker-compose with this environment

- Nginx 1.6.10
- PHP 7.2 loaded with ioncube
- MySQL 5.7

Wordpress, WHMCS, and phpmyadmin project are not included, download and extract it to the app folder.  
Any plugin for both software also not included.

For phpmyadmin you need to create config.inc.php manually and set the host
```php
$cfg['Servers'][$i]['host'] = "mysql"
```

If cert_path for whmcs, wordpress or phpmyadmin is not define, a self sign certificate will be created under server_name.   

You can use wildcard certificate by providing same file for both wordpress and whmcs.  

Do not change default docker-compose.yml other then setting the Environment variable for each service.  
You can add network alias to whmcs so wordpress can reach whmcs internally using fqdn example [here](https://docs.docker.com/compose/compose-file/#networks).

After setup your environment, run the service using
```bash
make up     # To Start
make down   # To Stop
```

In case your user id or group id is not 1000, you need to set USERID and GROUPID environment before running docker-compose. This is to make sure running container not changing file permission inside ./app folder

```bash
USERID=$(id -u) GROUPID=$(id -g) SFTP_PASSWORD="mysftppassword" docker-compose up -d
```

## Docker Service ##

|Service|Function|
|----|--------|
|nginx|web server for app template specified in ./docker/nginx/app|
|whmcs|php-fpm server for whmcs, app located in ./app/whmcs|
|wordpress|php-fpm server for wordpress, app located in ./app/wordpress|
|phpmyadmin|php-fpm server for phpmyadmin, app located in ./app/phpmyadmin. Don't forget to set config manually|
|cron|running php schedule job from file in ./app/cron|
|mysql|mysql server using folder ./mysql_data
|smtp|smtp server to send mail only. This is required so a sendmail request from application not run synchronusly. Can be set using gmail smtp. see configuration [here](https://hub.docker.com/r/namshi/smtp/).|
|sftp|sftp server to access all folder inside ./app. See configuration [here](https://hub.docker.com/r/atmoz/sftp)|
|memcached|For caching purpose, make sure wordpress and whmcs use same session|

If you use smtp service without any option, it might not be able to send email due to blacklisted by real server. In case it is blocked, for development purpose you can create a gmail account ( disable 2FA, enable Less Secure App ), and pass the credential to GMAIL_USER and GMAIL_PASSWORD environment in the smtp service.



## Docker Environment Variable ##

### nginx ###
|Environemt|Required|Default Value|Info|
|----|:----:|----|----|
|CERT_PATH|Y|/etc/nginx/certs|Nginx Certificate folder path|
|WORDPRESS_SERVER_NAME|Y|wordpress.test|Wordpress hostnames. Can be multiple name separated by single space e.g "wordpres.test www.wordpress.test" |
|WORDPRESS_CERT_PATH|N||Wordpress certificate path|
|WORDPRESS_CERT_KEY_PATH|N||Wordpress certificate key path|
|WHMCS_SERVER_NAME|Y|whmcs.test|Whmcs hostnames. Can be multiple name separated by single space |
|WHMCS_CERT_PATH|N||Whmcs certificate path|
|WHMCS_CERT_KEY_PATH|N||Whmcs certificate key path|
|PMA_SERVER_NAME|Y|pma.test|Phpmyadmin hostnames. Can be multiple name separted by single space |
|PMA_CERT_PATH|N||Phpmyadmin certificate path|
|PMA_CERT_KEY_PATH|N||Phpmyadmin certificate key path|
|REAL_IP_FROM|Y|172.16.0.0/12|Nginx real_ip_from directive value, a trusted subnet is preferable|
|SERVER_ADDR|Y||IP address of this Server, required for some license that lock to IP Address. Public IP Address is preferable|

### whmcs ###
|Environemt|Required|Default Value|Info|
|----|:----:|----|----|
|USERID|Y|1000|php-fpm run user id|
|GROUPID|Y|1000|php-fpm run group id|

### wordpress ###
|Environemt|Required|Default Value|Info|
|----|:----:|----|----|
|USERID|Y|1000|php-fpm run user id|
|GROUPID|Y|1000|php-fpm run group id|

### phpmyadmin ###
|Environemt|Required|Default Value|Info|
|----|:----:|----|----|
|USERID|Y|1000|php-fpm run user id|
|GROUPID|Y|1000|php-fpm run group id|

### cron ###
|Environemt|Required|Default Value|Info|
|----|:----:|----|----|
|USERID|Y|1000|php-fpm run user id|
|GROUPID|Y|1000|php-fpm run group id|

### mysql ###
Check [here](https://hub.docker.com/_/mysql) for other option

|Environemt|Required|Default Value|Info|
|----|:----:|----|----|
|MYSQL_ROOT_PASSWORD|Y|888888|MySQL root user password|
|MYSQL_USER|Y|test|MySQL application user|
|MYSQL_PASSWORD|Y|888888|MySQL application user password|

You need to change healthcheck --user and --password correspoding to above environment

## Docker Volume ##

All volume are mandatory

Wordpress, whmcs, and cron use the same custom php.ini file. If you need a separate php.ini file for each instance, create a separate file and change the mount volume path

### nginx ###
|Source|Destination|Permission|Info|
|----|----|:----:|----|
|./app/certs|/etc/nginx/certs|RO|Certificate file use by nginx|
|./app/whmcs|/srv/whmcs|RO|To provide whmcs non php static file by nginx|
|./app/wordpress|/srv/wordpress|RO|To provide wordpress non php static file by nginx|
|./app/phpmyadmin|/srv/phpmyadmin|RO|To provide phpmyadmin non php static file by nginx|
|/usr/share/zoneinfo/Asia/Jakarta|/etc/localtime|-|Container localtime|

### whmcs ###
|Source|Destination|Permission|Info|
|----|----|:----:|----|
|./app/whmcs|/var/www/whmcs|RW|WHMCS app folder|
|./app/php/php-fpm.ini|/usr/local/etc/php/conf.d/99_custom.ini|-|Custom PHP ini file|
|/usr/share/zoneinfo/Asia/Jakarta|/etc/localtime|-|Container localtime|

### wordpress ###
|Source|Destination|Permission|Info|
|----|----|:----:|----|
|./app/wordpress|/var/www/html|RW|Wordpress app folder|
|./app/php/php-fpm.ini|/usr/local/etc/php/conf.d/99_custom.ini|-|Custom PHP ini file|
|/usr/share/zoneinfo/Asia/Jakarta|/etc/localtime|-|Container localtime|

### phpmyadmin ###
|Source|Destination|Permission|Info|
|----|----|:----:|----|
|./app/phpmyadmin|/var/www/html|RW|Phpmyadmin app folder|
|/usr/share/zoneinfo/Asia/Jakarta|/etc/localtime|-|Container localtime|

### cron ###
|Source|Destination|Permission|Info|
|----|----|:----:|----|
|./app/cron|/cron|-|Cron job files. Will be merge and run as www-data|
|./app/whmcs|/var/www/html/whmcs|-|For executing application script by cron|
|./app/wordpress|/var/www/html/wordpress|-|For executing application script by cron|
|./app/php/php-fpm.ini|/usr/local/etc/php/conf.d/99_custom.ini|-|Custom PHP ini file|
|/usr/share/zoneinfo/Asia/Jakarta|/etc/localtime|-|Container localtime|

### mysql ###
|Source|Destination|Permission|Info|
|----|----|:----:|----|
|./init_db|docker-entrypoint-initdb.d|-|Init empty schema for application and set database user and privilege|
|./mysql_data|/var/lib/mysql|-|MySQL raw data, accessible by run user id|
|/usr/share/zoneinfo/Asia/Jakarta|/etc/localtime|-|Container localtime|

### sftp ###
|Source|Destination|Permission|Info|
|----|----|:----:|----|
|./app|/home/${USERID:-1000}/upload|-|Manage whole application file from ftp|

## Unsupported Feature ##
- We do not plan to implement mail server here, due to complexity of managing mail server security such as spam.
- Domain Manager also not available, we plan to use secns/powerdns in the future because it has simple UI. In the mean time it is best to use domain manager provided by your domain seller.
