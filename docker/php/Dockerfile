ARG IONCUBE_VERSION=7.2
FROM php:$IONCUBE_VERSION-fpm

ARG IONCUBE_VERSION=7.2

RUN apt-get update \
    && apt-get install -y libpng-dev libjpeg-dev libc-client-dev libkrb5-dev zlib1g-dev libicu-dev g++ libcurl4-gnutls-dev libxml2-dev libldap2-dev libmemcached-dev libmcrypt-dev cron procps 

# Memcached client
RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p /tmp/memcached \
    && tar -C /tmp/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && ( \
        cd /tmp/memcached \
        && phpize \
        && ./configure \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r /tmp/memcached  \
    && rm /tmp/memcached.tar.gz

# Enable ioncube
RUN curl -o /tmp/ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xzvf /tmp/ioncube.tar.gz -C /tmp \
    && mkdir -p /usr/local/lib/php/ioncube \
    && cp "/tmp/ioncube/ioncube_loader_lin_${IONCUBE_VERSION}.so" /usr/local/lib/php/ioncube/. \
    && echo "zend_extension = /usr/local/lib/php/ioncube/ioncube_loader_lin_$IONCUBE_VERSION.so" > /usr/local/etc/php/conf.d/00_ioncube.ini \
    && rm -r /tmp/ioncube \
    && rm /tmp/ioncube.tar.gz 

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && docker-php-ext-install gd \
    && docker-php-ext-install opcache \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install json \
    && docker-php-ext-install xml xmlrpc \
    && docker-php-ext-install intl \ 
    && docker-php-ext-install curl \ 
    && docker-php-ext-install zip \
    && docker-php-ext-install ldap \
    && docker-php-ext-install iconv \
    && docker-php-ext-install soap \
    && docker-php-ext-enable memcached \
    && apt-get purge -y libc-client-dev libkrb5-dev libicu-dev g++ libcurl4-gnutls-dev libxml2-dev libldap2-dev \  
    && apt-get -y --purge autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/list/* /tmp/* /var/tmp/*

COPY ./start-cron.sh /usr/local/bin/start-cron
COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/local/sbin/php-fpm", "-F", "--pid=/tmp/php-fpm.pid"]

