#!/bin/bash
service cron stop
cat /cron/* | crontab -u www-data -
cron -f -L 8
