#!/bin/bash
mkdir -p ${CERT_PATH}

if [[ ! -w "${CERT_PATH}" ]]; then 
    ROOT_CERT_PATH="/root/"
else
    ROOT_CERT_PATH=${CERT_PATH}
fi

PASSPHRASE_FILE="${ROOT_CERT_PATH}/passphrase.txt"
CERT_ENVS=$(env | grep -E "*_CERT_PATH")
while read -r CERT_ENV; do
    CERT_FILE=$(echo "${CERT_ENV}" | cut -f2 -d "=")
    if [[ ! -f "${CERT_FILE}" ]]; then
        CERT_NAME=$(echo "${CERT_ENV}" | cut -f1 -d "=" )
        APP_NAME="${CERT_NAME%%_CERT_PATH}"
        APP_SERVER_NAME_ENV="${APP_NAME}_SERVER_NAME"
        APP_SERVER_NAME=$(echo "${!APP_SERVER_NAME_ENV}" | cut -f1 -d " " )

        printf "\n==============================================================================\n"
        printf "Generate Self Signed Certificate for ${APP_SERVER_NAME}\n\n"
        if [[ ! -f "${ROOT_CERT_PATH}/passphrase.txt" ]]; then
            openssl rand -base64 32 > "${PASSPHRASE_FILE}"
        fi

        openssl genrsa -aes256 -passout file:"${PASSPHRASE_FILE}" -out "${ROOT_CERT_PATH}/${APP_SERVER_NAME}.key" 2048
        openssl req -new -passin file:"${PASSPHRASE_FILE}" -key "${ROOT_CERT_PATH}/${APP_SERVER_NAME}.key" -out "${ROOT_CERT_PATH}/${APP_SERVER_NAME}.csr" -subj "/C=ID/O=DEV/OU=IT/CN=${APP_SERVER_NAME}"
        cp "${ROOT_CERT_PATH}/${APP_SERVER_NAME}.key" "${ROOT_CERT_PATH}/${APP_SERVER_NAME}.key.org"
        openssl rsa -in "${ROOT_CERT_PATH}/${APP_SERVER_NAME}.key.org" -passin file:"${PASSPHRASE_FILE}" -out "${ROOT_CERT_PATH}/${APP_SERVER_NAME}.key"
        openssl x509 -req -days 3650 -in "${ROOT_CERT_PATH}/${APP_SERVER_NAME}.csr" -signkey "${ROOT_CERT_PATH}/${APP_SERVER_NAME}.key" -out "${ROOT_CERT_PATH}/${APP_SERVER_NAME}.crt"
        export ${APP_NAME}_CERT_PATH="${ROOT_CERT_PATH}/${APP_SERVER_NAME}.crt"
        export ${APP_NAME}_CERT_KEY_PATH="${ROOT_CERT_PATH}/${APP_SERVER_NAME}.key"
        printf "==============================================================================\n"
    fi
done <<< "${CERT_ENVS}"

TMPL_FILE=./app/*.tmpl
for TMPL in ${TMPL_FILE}
do
    FILE_NAME="${TMPL##*/}"
    dockerize -template "${TMPL}" > "/etc/nginx/conf.d/${FILE_NAME%.*}.conf"
done

exec "$@"
