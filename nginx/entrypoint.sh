#!/usr/bin/env bash

nginxIniFile="/etc/nginx/conf.d/default.conf"

# Nginx changes
sed -i "s:root /var/www/html/public;*:root $NGINX_DOCUMENT_ROOT;:g" $nginxIniFile

nginx -g "daemon off;"