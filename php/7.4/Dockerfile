FROM php:7.4-fpm-alpine
LABEL maintainer=dersonsena@gmail.com \
      vendor=Cabra.dev

ENV TERM="xterm"
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"

# PHP Env Variables
ENV PHP_DATE_TIMEZONE=America/Sao_Paulo
ENV PHP_DISPLAY_ERRORS=On
ENV PHP_MEMORY_LIMIT=256M
ENV PHP_MAX_EXECUTION_TIME=60
ENV PHP_POST_MAX_SIZE=50M
ENV PHP_UPLOAD_MAX_FILESIZE=50M

# XDebug Env Variables
ENV XDEBUG_MODE=debug
ENV XDEBUG_START_WITH_REQUEST=yes
ENV XDEBUG_DISCOVER_CLIENT_HOST=1
ENV XDEBUG_CLIENT_HOST=host.docker.internal
ENV XDEBUG_CLIENT_PORT=9003
ENV XDEBUG_MAX_NESTING_LEVEL=1500
ENV XDEBUG_IDE_KEY=PHPSTORM
ENV XDEBUG_LOG=/tmp/xdebug.log
ENV PHP_IDE_CONFIG="serverName=_"

# Versioning Env Vars
ENV XDEBUG_VERSION=3.0.2
ENV MONGODB_VERSION=1.10.0alpha1
ENV REDIS_VERSION=5.3.4
ENV COMPOSER_VERSION=2.1.3
ENV GIT_VERSION=2.34.1-r0

RUN apk update && apk add --no-cache --update \
    $PHPIZE_DEPS \
    bash \
    git=${GIT_VERSION} \
    nano \
    vim \
    g++ \
    gcc \
    curl \
    libxml2 \
    zip \
    unzip \
    wget \
    moreutils \
    tzdata \
    freetype \
    graphicsmagick \
    file \
    shadow \
    autoconf \
    make \
    libtool \
    icu-libs \
    zlib \
    libgomp \
    icu-dev \
    zlib-dev \
    libzip-dev \
    curl-dev \
    postgresql-dev \
    libxml2-dev \
    oniguruma-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    freetype-dev \
    pcre-dev \
    yaml-dev \
    libmcrypt-dev \
    sqlite-dev \
    freetds-dev \
    jpeg-dev \
    openldap-dev \
    libxslt-dev \
    rabbitmq-c-dev

RUN docker-php-ext-install pdo \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install pgsql pdo_pgsql \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install intl \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install sockets \
    && docker-php-ext-install soap \
    && docker-php-ext-install zip \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install curl \
    && docker-php-ext-install exif \
    && docker-php-ext-install calendar \
    && docker-php-ext-install ldap \
    && docker-php-ext-install pdo_dblib \
    && docker-php-ext-install xsl \
    && docker-php-ext-install opcache \
    && docker-php-ext-install tokenizer \
    && docker-php-ext-install iconv \
    && docker-php-ext-install exif

# Installing GD extension
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Installing Imagemagick
RUN set -ex \
    && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS imagemagick-dev libtool \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && pecl install imagick \
    && docker-php-ext-enable --ini-name 20-imagick.ini imagick \
    && apk add --no-cache --virtual .imagick-runtime-deps imagemagick \
    && apk del .phpize-deps

# Installing PCOV
RUN pecl install pcov && docker-php-ext-enable pcov

# Installing YAML
RUN pecl install -o -f yaml && docker-php-ext-enable yaml

# Installing Mcrypt extension
RUN pecl install -o -f mcrypt && docker-php-ext-enable mcrypt

# Installing Mongodb extension
RUN mkdir -p /usr/src/php/ext/mongodb \
    && curl -fsSL https://pecl.php.net/get/mongodb-${MONGODB_VERSION} | tar xvz -C "/usr/src/php/ext/mongodb" --strip 1 \
    && docker-php-ext-install mongodb

# Installing Redis extension
RUN pecl install -o -f redis-${REDIS_VERSION} && docker-php-ext-enable redis

# Installing XDebug
RUN pecl install -o -f xdebug-${XDEBUG_VERSION} && docker-php-ext-enable xdebug

# Installing AMQP
RUN pecl install -o -f amqp && docker-php-ext-enable amqp

RUN php -m

RUN apk del $PHPIZE_DEPS
RUN rm -rf /var/cache/apk/*

# Making copy of php.ini development file
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
 
RUN curl -fsSL https://getcomposer.org/installer | php -- --version=${COMPOSER_VERSION} --install-dir=/usr/local/bin --filename=composer

COPY entrypoint.sh /etc/entrypoint.sh
RUN chmod +x /etc/entrypoint.sh
RUN sh /etc/entrypoint.sh

WORKDIR /
EXPOSE 9000
ENTRYPOINT ["/etc/entrypoint.sh"]