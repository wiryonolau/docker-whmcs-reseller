#!/bin/bash
mkdir -p ${CERT_PATH}

if [ -z "${WORDPRESS_CERT_FILE}" ]; then
    openssl rand -base64 32 > ${CERT_PATH}/wp_passphrase.txt
    openssl genrsa -aes256 -passout file:${CERT_PATH}/wp_passphrase.txt -out ${CERT_PATH}/wp.key 2048
    openssl req -new -passin file:${CERT_PATH}/wp_passphrase.txt -key ${CERT_PATH}/wp.key -out ${CERT_PATH}/wp.csr -subj "/C=ID/O=DEV/OU=IT/CN=${WORDPRESS_SERVER_NAME}"
    cp ${CERT_PATH}/wp.key ${CERT_PATH}/wp.key.org
    openssl rsa -in ${CERT_PATH}/wp.key.org -passin file:${CERT_PATH}/wp_passphrase.txt -out ${CERT_PATH}/wp.key
    openssl x509 -req -days 3650 -in ${CERT_PATH}/wp.csr -signkey ${CERT_PATH}/wp.key -out ${CERT_PATH}/wp.crt
    export WORDPRESS_CERT_FILE="${CERT_PATH}/wp.crt"
    export WORDPRESS_CERT_KEY_FILE="${CERT_PATH}/wp.key"
fi

if [ -z "${WHMCS_CERT_FILE}" ]; then
    openssl rand -base64 32 > ${CERT_PATH}/whmcs_passphrase.txt
    openssl genrsa -aes256 -passout file:${CERT_PATH}/whmcs_passphrase.txt -out ${CERT_PATH}/whmcs.key 2048
    openssl req -new -passin file:${CERT_PATH}/whmcs_passphrase.txt -key ${CERT_PATH}/whmcs.key -out ${CERT_PATH}/whmcs.csr -subj "/C=ID/O=DEV/OU=IT/CN=${WHMCS_SERVER_NAME}"
    cp ${CERT_PATH}/whmcs.key ${CERT_PATH}/whmcs.key.org
    openssl rsa -in ${CERT_PATH}/whmcs.key.org -passin file:${CERT_PATH}/whmcs_passphrase.txt -out ${CERT_PATH}/whmcs.key
    openssl x509 -req -days 3650 -in ${CERT_PATH}/whmcs.csr -signkey ${CERT_PATH}/whmcs.key -out ${CERT_PATH}/whmcs.crt
    export WHMCS_CERT_FILE="${CERT_PATH}/whmcs.crt"
    export WHMCS_CERT_KEY_FILE="${CERT_PATH}/whmcs.key"
fi

dockerize -template /app/default.tmpl > /etc/nginx/conf.d/default.conf
dockerize -template /app/whmcs.tmpl > /etc/nginx/conf.d/whmcs.conf
dockerize -template /app/wordpress.tmpl > /etc/nginx/conf.d/wordpress.conf

exec "$@"
