# WHMCS + Wordpress run using docker #

Provide base structure to run both whmcs and wordpress for marketing using this environment

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
Currently not support Letsencrypt.

Do not change default docker-compose.yml other then setting the Environment variable for each service

After setup your environment, run the service using
```bash
make up     # To Start
make down   # To Stop
```

## Environment Variable ##

```bash
nginx:
    CERT_PATH=/etc/nginx/certs              # Certificate path
    WORDPRESS_SERVER_NAME=wordpress.test    # Wordpress hostnames
    WORDPRESS_CERT_PATH=                    # Wordpress certificate path
    WORDPRESS_CERT_KEY_PATH=                # Wordpress certificate key path
    WHMCS_SERVER_NAME=whmcs.test            # Whmcs hostnames
    WHMCS_CERT_PATH=                        # Whmcs certificate path
    WHMCS_CERT_KEY_PATH=                    # Whmcs certificate key path
    PMA_SERVER_NAME=pma.test                # Phpmyadmin hostnames
    PMA_CERT_PATH=                          # Phpmyadmin certificate path    
    PMA_CERT_KEY_PATH=                      # Phpmyadmin certificate key path    
    SERVER_REAL_IP=                         # Container netowrk ip subnet use by nginx
whmcs:
    USERID=                                 # Run user , pass as current user from Makefile
    GROUPID=                                # Run group , pass as current user group from Makefile
wordpress:
    USERID=                                 # Run user , pass as current user from Makefile
    GROUPID=                                # Run group , pass as current user group from Makefile
phpmyadmin:
    USERID=                                 # Run user , pass as current user from Makefile
    GROUPID=                                # Run group , pass as current user group from Makefile
cron:
    USERID=                                 # Run user , pass as current user from Makefile
    GROUPID=                                # Run group , pass as current user group from Makefile
mysql:
    MYSQL_ROOT_PASSWORD=
    MYSQL_USER=
    MYSQL_PASSWORD=    
```

## Volume ##
```bash
nginx:
    /etc/nginx/certs            # Certificate file
    /var/www/html/whmcs         # For static file, share with whmcs:/var/www/whmcs
    /var/www/html/wordpress     # For static file, share with wordpress:/var/www/html
    /var/www/html/phpmyadmin    # For static file, share with phpmyadmin:/var/www/html
    /etc/localtime              # Default Asia/Jakarta
whmcs:
    /var/www/whmcs              # Your own whmcs file
    /etc/localtime              # Default Asia/Jakarta
wordpress:
    /var/www/html               # Your own wordpress file
    /etc/localtime              # Default Asia/Jakarta
phpmyadmin:
    /var/www/html               # Your own phpmyadmin file
    /etc/localtime              # Default Asia/Jakarta
cron:
    /cron                       # Cron job, will be run as www-data
    /var/www/html/whmcs         # For executing cron, share with whmcs:/var/www/whmcs
    /var/www/html/wordpress     # For executing cron, share with wordpress:/var/www/html
    /etc/localtime              # Default Asia/Jakarta
mysql:
    /docker-entrypoint-initdb.d # From ./init_db folder
    /var/lib/mysql              # Default ./mysql_data
    /etc/localtime              # Default Asia/Jakarta
```
