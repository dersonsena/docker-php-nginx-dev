FROM php:7.4-fpm-alpine
LABEL maintainer="Kilderson Sena <dersonsena@gmail.com>"

# PHP Env Variables
ENV PHP_DATE_TIMEZONE=America/Sao_Paulo
ENV PHP_DISPLAY_ERRORS=On
ENV PHP_MEMORY_LIMIT=256M
ENV PHP_MAX_EXECUTION_TIME=60
ENV PHP_POST_MAX_SIZE=50M
ENV PHP_UPLOAD_MAX_FILESIZE=50M

# XDebug Env Variables
ENV XDEBUG_VERSION=3.0.2
ENV XDEBUG_MODE=debug
ENV XDEBUG_START_WITH_REQUEST=default
ENV XDEBUG_REMOTE_AUTOSTART=1
ENV XDEBUG_REMOTE_CONNECT_BACK=0
ENV XDEBUG_CLIENT_HOST=host.docker.internal
ENV XDEBUG_CLIENT_PORT=9000
ENV XDEBUG_REMOTE_HOST=host.docker.internal
ENV XDEBUG_REMOTE_PORT=9000
ENV XDEBUG_MAX_NESTING_LEVEL=1500
ENV XDEBUG_IDE_KEY=PHPSTORM

# MongoDB Env Variables
ENV MONGODB_VERSION=1.5.2

# Composer Env Variables
ENV COMPOSER_VERSION=2.0.9

RUN apk update --no-cache && apk add \
    libzip-dev \
    git \
    nano \
    g++ \
    gcc \
    curl \
    curl-dev \
    postgresql-dev \
    libxml2 \
    libxml2-dev \
    imagemagick \
    graphicsmagick \
    zip \
    unzip \
    wget \
    moreutils \
    icu-dev \
    oniguruma-dev \
    tzdata \
    freetype \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    nginx \
    imagemagick-dev \
    imagemagick \
    file \
    shadow \
    autoconf \
    make \
    libtool \
    pcre-dev \
    yaml-dev \
    libmcrypt-dev \
    sqlite-dev

RUN docker-php-ext-install pdo \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install pgsql pdo_pgsql \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install json \
    && docker-php-ext-install xml \
    && docker-php-ext-install intl \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install sockets \
    && docker-php-ext-install soap \
    && docker-php-ext-install zip \
    && docker-php-ext-install iconv \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install curl \
    && docker-php-ext-install pdo_sqlite

# Installing GD extension
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Installing Imagemagick
RUN pecl install -o -f imagick && docker-php-ext-enable imagick

# Installing YAML
RUN pecl install -o -f yaml && docker-php-ext-enable yaml

# Installing Mcrypt extension
RUN pecl install -o -f mcrypt && docker-php-ext-enable mcrypt

# Installing Mongodb extension
RUN pecl install -o -f mongodb-${MONGODB_VERSION} && docker-php-ext-enable mongodb

# Installing Redis extension
RUN pecl install -o -f redis && docker-php-ext-enable redis

# Installing XDebug
RUN pecl install -o -f xdebug-${XDEBUG_VERSION} && docker-php-ext-enable xdebug

ENV XDEBUG_INI_FILE=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.mode=${XDEBUG_MODE}" >> ${XDEBUG_INI_FILE} \
    && echo "xdebug.start_with_request=${XDEBUG_START_WITH_REQUEST}" >> ${XDEBUG_INI_FILE} \ 
    && echo "xdebug.remote_autostart=${XDEBUG_REMOTE_AUTOSTART}" >> ${XDEBUG_INI_FILE} \
    && echo "xdebug.remote_connect_back=${XDEBUG_REMOTE_CONNECT_BACK}" >> ${XDEBUG_INI_FILE} \
    && echo "xdebug.client_host=${XDEBUG_CLIENT_HOST}" >> ${XDEBUG_INI_FILE} \
    && echo "xdebug.client_port=${XDEBUG_CLIENT_PORT}" >> ${XDEBUG_INI_FILE} \
    && echo "xdebug.remote_host=${XDEBUG_REMOTE_HOST}" >> ${XDEBUG_INI_FILE} \
    && echo "xdebug.remote_port=${XDEBUG_REMOTE_PORT}" >> ${XDEBUG_INI_FILE} \
    && echo "xdebug.idekey=${XDEBUG_IDE_KEY}" >> ${XDEBUG_INI_FILE} \
    && echo "xdebug.max_nesting_level=${XDEBUG_MAX_NESTING_LEVEL}" >> ${XDEBUG_INI_FILE}

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

ENV PHP_INI_FILE=/usr/local/etc/php/php.ini
RUN sed -i 's/memory_limit.*/memory_limit = ${PHP_MEMORY_LIMIT}/' ${PHP_INI_FILE} \
    && sed -i 's/date.timezone.*/date.timezone = ${PHP_DATE_TIMEZONE}/' ${PHP_INI_FILE} \
    && sed -i 's/display_errors = On.*/display_errors = ${PHP_DISPLAY_ERRORS}/' ${PHP_INI_FILE} \
    && sed -i 's/max_execution_time.*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/' ${PHP_INI_FILE} \
    && sed -i 's/post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/' ${PHP_INI_FILE} \
    && sed -i 's/upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/' ${PHP_INI_FILE}

RUN rm -rf /var/cache/apk/*
 
RUN curl -sS https://getcomposer.org/installer | php -- --version=${COMPOSER_VERSION} --install-dir=/usr/bin --filename=composer

## Setup of Nginx
COPY ./nginx.conf /etc/nginx/

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]