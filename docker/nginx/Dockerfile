FROM nginx:stable

ARG DOCKERIZE_VERSION=v0.6.1

ENV CERT_PATH=/etc/nginx/certs \
    WORDPRESS_SERVER_NAME=wordpress.test \
    WORDPRESS_CERT_PATH= \
    WORDPRESS_CERT_KEY_PATH= \
    WHMCS_SERVER_NAME=whmcs.test \
    WHMCS_CERT_PATH= \
    WHMCS_CERT_KEY_PATH= \
    PMA_SERVER_NAME=pma.test \
    PMA_CERT_PATH= \
    PMA_CERT_KEY_PATH=

RUN apt-get update \
    && apt-get install -y wget openssl inetutils-ping inetutils-telnet \
    && apt-get -y --purge autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY ./app /app

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["./docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
