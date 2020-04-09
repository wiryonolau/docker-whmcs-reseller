#!/bin/bash

USERID=${USERID:-1000}
GROUPID=${GROUPID:-1000}

usermod -u ${USERID} www-data
groupmod -g ${USERID} www-data

mkdir -p /run/php 
chown -R www-data:www-data /run/php

exec "$@"
