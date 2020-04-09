#!/bin/bash
mkdir -p ${CERT_PATH}

if [[ ! -w "${CERT_PATH}" ]]; then 
    ROOT_CERT_PATH=/tmp
else
    ROOT_CERT_PATH=${CERT_PATH}
fi

if [[ ! -f "${WORDPRESS_CERT_PATH}" ]]; then
    openssl rand -base64 32 > ${ROOT_CERT_PATH}/wp_passphrase.txt
    openssl genrsa -aes256 -passout file:${ROOT_CERT_PATH}/wp_passphrase.txt -out ${ROOT_CERT_PATH}/wp.key 2048
    openssl req -new -passin file:${ROOT_CERT_PATH}/wp_passphrase.txt -key ${ROOT_CERT_PATH}/wp.key -out ${ROOT_CERT_PATH}/wp.csr -subj "/C=ID/O=DEV/OU=IT/CN=${WORDPRESS_SERVER_NAME}"
    cp ${ROOT_CERT_PATH}/wp.key ${ROOT_CERT_PATH}/wp.key.org
    openssl rsa -in ${ROOT_CERT_PATH}/wp.key.org -passin file:${ROOT_CERT_PATH}/wp_passphrase.txt -out ${ROOT_CERT_PATH}/wp.key
    openssl x509 -req -days 3650 -in ${ROOT_CERT_PATH}/wp.csr -signkey ${ROOT_CERT_PATH}/wp.key -out ${ROOT_CERT_PATH}/wp.crt
    export WORDPRESS_CERT_PATH="${ROOT_CERT_PATH}/wp.crt"
    export WORDPRESS_CERT_KEY_PATH="${ROOT_CERT_PATH}/wp.key"
fi

if [[ ! -f "${WHMCS_CERT_PATH}" ]]; then
    openssl rand -base64 32 > ${ROOT_CERT_PATH}/whmcs_passphrase.txt
    openssl genrsa -aes256 -passout file:${ROOT_CERT_PATH}/whmcs_passphrase.txt -out ${ROOT_CERT_PATH}/whmcs.key 2048
    openssl req -new -passin file:${ROOT_CERT_PATH}/whmcs_passphrase.txt -key ${ROOT_CERT_PATH}/whmcs.key -out ${ROOT_CERT_PATH}/whmcs.csr -subj "/C=ID/O=DEV/OU=IT/CN=${WHMCS_SERVER_NAME}"
    cp ${ROOT_CERT_PATH}/whmcs.key ${ROOT_CERT_PATH}/whmcs.key.org
    openssl rsa -in ${ROOT_CERT_PATH}/whmcs.key.org -passin file:${ROOT_CERT_PATH}/whmcs_passphrase.txt -out ${ROOT_CERT_PATH}/whmcs.key
    openssl x509 -req -days 3650 -in ${ROOT_CERT_PATH}/whmcs.csr -signkey ${ROOT_CERT_PATH}/whmcs.key -out ${ROOT_CERT_PATH}/whmcs.crt
    export WHMCS_CERT_PATH="${ROOT_CERT_PATH}/whmcs.crt"
    export WHMCS_CERT_KEY_PATH="${ROOT_CERT_PATH}/whmcs.key"
fi

dockerize -template /app/default.tmpl > /etc/nginx/conf.d/default.conf
dockerize -template /app/whmcs.tmpl > /etc/nginx/conf.d/whmcs.conf
dockerize -template /app/wordpress.tmpl > /etc/nginx/conf.d/wordpress.conf

exec "$@"
