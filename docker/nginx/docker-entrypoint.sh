#!/bin/bash
mkdir -p ${CERT_PATH}

if [ ! -f "${WORDPRESS_CERT_FILE}" ]; then
    if [ ! -w "${CERT_PATH}" ]; then 
        WORDPRESS_CERT_PATH=/tmp
    else
        WORDPRESS_CERT_PATH=${CERT_PATH}
    fi
    openssl rand -base64 32 > ${WORDPRESS_CERT_PATH}/wp_passphrase.txt
    openssl genrsa -aes256 -passout file:${WORDPRESS_CERT_PATH}/wp_passphrase.txt -out ${WORDPRESS_CERT_PATH}/wp.key 2048
    openssl req -new -passin file:${WORDPRESS_CERT_PATH}/wp_passphrase.txt -key ${WORDPRESS_CERT_PATH}/wp.key -out ${WORDPRESS_CERT_PATH}/wp.csr -subj "/C=ID/O=DEV/OU=IT/CN=${WORDPRESS_SERVER_NAME}"
    cp ${WORDPRESS_CERT_PATH}/wp.key ${WORDPRESS_CERT_PATH}/wp.key.org
    openssl rsa -in ${WORDPRESS_CERT_PATH}/wp.key.org -passin file:${WORDPRESS_CERT_PATH}/wp_passphrase.txt -out ${WORDPRESS_CERT_PATH}/wp.key
    openssl x509 -req -days 3650 -in ${WORDPRESS_CERT_PATH}/wp.csr -signkey ${WORDPRESS_CERT_PATH}/wp.key -out ${WORDPRESS_CERT_PATH}/wp.crt
    export WORDPRESS_CERT_FILE="${WORDPRESS_CERT_PATH}/wp.crt"
    export WORDPRESS_CERT_KEY_FILE="${WORDPRESS_CERT_PATH}/wp.key"
fi

if [ ! -f "${WHMCS_CERT_FILE}" ]; then
    if [ ! -w "${CERT_PATH}" ]; then 
        WHMCS_CERT_PATH=/tmp
    else
        WHMCS_CERT_PATH=${CERT_PATH}
    fi
    openssl rand -base64 32 > ${WHMCS_CERT_PATH}/whmcs_passphrase.txt
    openssl genrsa -aes256 -passout file:${WHMCS_CERT_PATH}/whmcs_passphrase.txt -out ${WHMCS_CERT_PATH}/whmcs.key 2048
    openssl req -new -passin file:${WHMCS_CERT_PATH}/whmcs_passphrase.txt -key ${WHMCS_CERT_PATH}/whmcs.key -out ${WHMCS_CERT_PATH}/whmcs.csr -subj "/C=ID/O=DEV/OU=IT/CN=${WHMCS_SERVER_NAME}"
    cp ${WHMCS_CERT_PATH}/whmcs.key ${WHMCS_CERT_PATH}/whmcs.key.org
    openssl rsa -in ${WHMCS_CERT_PATH}/whmcs.key.org -passin file:${WHMCS_CERT_PATH}/whmcs_passphrase.txt -out ${WHMCS_CERT_PATH}/whmcs.key
    openssl x509 -req -days 3650 -in ${WHMCS_CERT_PATH}/whmcs.csr -signkey ${WHMCS_CERT_PATH}/whmcs.key -out ${WHMCS_CERT_PATH}/whmcs.crt
    export WHMCS_CERT_FILE="${WHMCS_CERT_PATH}/whmcs.crt"
    export WHMCS_CERT_KEY_FILE="${WHMCS_CERT_PATH}/whmcs.key"
fi

dockerize -template /app/default.tmpl > /etc/nginx/conf.d/default.conf
dockerize -template /app/whmcs.tmpl > /etc/nginx/conf.d/whmcs.conf
dockerize -template /app/wordpress.tmpl > /etc/nginx/conf.d/wordpress.conf

exec "$@"
