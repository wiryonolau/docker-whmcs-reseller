# WHMCS + Wordpress run using docker #

Provide base structure to run both whmcs and wordpress for marketing using this environment

- Nginx 1.6.10
- PHP 7.2 loaded with ioncube
- MySQL 5.7

Wordpress and WHMCS project are not included.  
Any plugin for both software also not included.

If cert_path for whmcs or wordpress not define, a self sign certificate will be created under server_name.  
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
    WORDPRESS_SERVER_NAME=wordpress.dev     # Wordpress root url
    WORDPRESS_CERT_PATH=                    # Wordpress certificate path
    WORDPRESS_CERT_KEY_PATH=                # Wordpress certificate key path
    WHMCS_SERVER_NAME=whmcs.dev             # Whmcs root url
    WHMCS_CERT_PATH=                        # Whmcs certificate path
    WHMCS_CERT_KEY_PATH=                    # Whmcs certificate key path
    SERVER_REAL_IP=                          # Container netowrk ip subnet use by nginx
whmcs:
    USERID=                                 # Run user , pass as current user from Makefile
    GROUPID=                                # Run group , pass as current user group from Makefile
wordpress:
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
    /etc/localtime              # Default Asia/Jakarta
whmcs:
    /var/www/whmcs              # Your own whmcs file
    /etc/localtime              # Default Asia/Jakarta
wordpress:
    /var/www/html               # Your own wordpress file
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
