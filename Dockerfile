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
ENV XDEBUG_MODE=debug
ENV XDEBUG_START_WITH_REQUEST=default
ENV XDEBUG_DISCOVER_CLIENT_HOST=true
ENV XDEBUG_CLIENT_HOST=host.docker.internal
ENV XDEBUG_CLIENT_PORT=9000
ENV XDEBUG_MAX_NESTING_LEVEL=1500
ENV XDEBUG_IDE_KEY=PHPSTORM

# Versioning Env Vars
ENV XDEBUG_VERSION=3.0.2
ENV MONGODB_VERSION=1.5.2
ENV COMPOSER_VERSION=2.0.9
ENV NGINX_VERSION=1.18.0-r13
ENV GIT_VERSION=2.30.1-r0

RUN apk update --no-cache && apk add \
    libzip-dev \
    git=${GIT_VERSION} \
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
    nginx=${NGINX_VERSION} \
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

# Making copy of php.ini development file
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
    
RUN rm -rf /var/cache/apk/*
 
RUN curl -sS https://getcomposer.org/installer | php -- --version=${COMPOSER_VERSION} --install-dir=/usr/bin --filename=composer

## Setup of Nginx
RUN rm /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./nginx/nginx.conf /etc/nginx/
COPY ./nginx/default.conf /etc/nginx/conf.d/

# Creating self-signed SSL Certificate to Nginx
RUN mkdir /etc/nginx/certs && openssl req \
    -subj "/C=US/ST=New York/L=Rochester/O=Localhost SA/OU=Development/CN=localhost/emailAddress=john@gmail.com" \
    -new -newkey rsa:2048 -sha256 -days 1095 -nodes -x509 -keyout \
    /etc/nginx/certs/certificate.key -out /etc/nginx/certs/certificate.crt

EXPOSE 80 443

WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html
RUN chown -R www-data:www-data /var/lib/nginx

COPY entrypoint.sh /etc/entrypoint.sh
RUN chmod +x /etc/entrypoint.sh

ENTRYPOINT ["/etc/entrypoint.sh"]