#!/usr/bin/env bash

phpIniFile="/usr/local/etc/php/php.ini"
xdebugIniFile="/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"

# PHP configuration changes
sed -i "s:;date.timezone.*:date.timezone =:g" $phpIniFile
sed -i "s:date.timezone.*:date.timezone = $PHP_DATE_TIMEZONE:g" $phpIniFile
sed -i "s:memory_limit.*:memory_limit = $PHP_MEMORY_LIMIT:g" $phpIniFile
sed -i "s:display_errors = On.*:display_errors = $PHP_DISPLAY_ERRORS:g" $phpIniFile
sed -i "s:max_execution_time.*:max_execution_time = $PHP_MAX_EXECUTION_TIME:g" $phpIniFile
sed -i "s:post_max_size.*:post_max_size = $PHP_POST_MAX_SIZE:g" $phpIniFile
sed -i "s:upload_max_filesize.*:upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE:g" $phpIniFile

# XDebug configuration changes
echo "xdebug.mode=$XDEBUG_MODE" >> $xdebugIniFile
echo "xdebug.cli_color=1" >> $xdebugIniFile
echo "xdebug.start_with_request = $XDEBUG_START_WITH_REQUEST" >> $xdebugIniFile
echo "xdebug.discover_client_host = $XDEBUG_DISCOVER_CLIENT_HOST" >> $xdebugIniFile
echo "xdebug.client_host = $XDEBUG_CLIENT_HOST" >> $xdebugIniFile
echo "xdebug.client_port = $XDEBUG_CLIENT_PORT" >> $xdebugIniFile
echo "xdebug.idekey = $XDEBUG_IDE_KEY" >> $xdebugIniFile
echo "xdebug.max_nesting_level = $XDEBUG_MAX_NESTING_LEVEL" >> $xdebugIniFile
echo "xdebug.log=$XDEBUG_LOG" >> $xdebugIniFile

php-fpm -D