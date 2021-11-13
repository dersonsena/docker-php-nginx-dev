# PHP 7.4 FPM + NGINX Dev Enviroment

Image composition and versions below:

- PHP FPM 7.4 or 8.0
- XDebug 3.0.2
- NGINX 1.20.1-r3
- Composer 2.1.3
- Git 2.32.0-r0
- Redis PHP Extension 5.3.4
- MongoDB PHP Extension 1.10.0alpha1

## CLI
```bash
docker run -d --name project-app -v "$PWD":/var/www/html -p 80:80 -p 443:443 dersonsena/php-nginx-dev:8.0
```

## Docker Compose

### Minimal to use

The snipet below show the **minimal setup**:

```yaml
version: '3.5'
services:
  app:
    container_name: project-app
    image: dersonsena/php-nginx-dev:8.0
    volumes:
      - ./:/var/www/html
    ports:
      - '80:80'
      - '443:443'
    networks:
      - project-network

networks:
  project-network:
    driver: bridge
```

### PHP

You can customize some php ini params. The possibles variables and their default values are shown below:

```yaml
version: '3.5'
services:
  app:
    container_name: project-app
    image: dersonsena/php-nginx-dev:8.0
    volumes:
      - ./:/var/www/html
    ports:
      - '80:80'
      - '443:443'
    environment:
      - PHP_DATE_TIMEZONE=America/Sao_Paulo
      - PHP_DISPLAY_ERRORS=On
      - PHP_MEMORY_LIMIT=256M
      - PHP_MAX_EXECUTION_TIME=60
      - PHP_POST_MAX_SIZE=50M
      - PHP_UPLOAD_MAX_FILESIZE=50M
    networks:
      - project-network

networks:
  project-network:
    driver: bridge
```

If you want to use a custom `php.ini` file, just create one in your project, such as `.docker/php/php.ini`, and map volume like below:

```yaml
...
volumes:
  - ./:/var/www/html
  - ./.docker/php:/usr/local/etc/php
...
```

> **TIP**: to make your life easier you can use the original php.ini file placed in root level of this repository.

#### Installed PHP Extensions

```bash
$ php -m

[PHP Modules]
amqp
bcmath
calendar
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
hash
iconv
intl
json
ldap
libxml
mbstring
mcrypt
mongodb
mysqli
mysqlnd
openssl
pcntl
pcov
pcre
PDO
pdo_dblib
pdo_mysql
pdo_pgsql
pdo_sqlite
pgsql
Phar
posix
readline
redis
Reflection
session
SimpleXML
soap
sockets
sodium
SPL
sqlite3
standard
tokenizer
xdebug
xml
xmlreader
xmlwriter
xsl
yaml
Zend OPcache
zip
zlib

[Zend Modules]
Xdebug
Zend OPcache
```

### XDebug

You can customize some xdebug params. The possibles variables and their default values are shown below:

```yaml
version: '3.5'
services:
  app:
    container_name: project-app
    image: dersonsena/php-nginx-dev:8.0
    volumes:
      - ./:/var/www/html
    ports:
      - '80:80'
      - '443:443'
    environment:
      - XDEBUG_MODE=develop,debug
      - XDEBUG_START_WITH_REQUEST=yes
      - XDEBUG_DISCOVER_CLIENT_HOST=0
      - XDEBUG_CLIENT_HOST=host.docker.internal
      - XDEBUG_CLIENT_PORT=9003
      - XDEBUG_MAX_NESTING_LEVEL=1500
      - XDEBUG_IDE_KEY=PHPSTORM
      - XDEBUG_LOG=/tmp/xdebug.log
    networks:
      - project-network

networks:
  project-network:
    driver: bridge
```

Just on **MacOs environment**, use this configurations to use xdebug:

```yaml
...
environment:
  - XDEBUG_START_WITH_REQUEST=yes
  - XDEBUG_DISCOVER_CLIENT_HOST=0
  - XDEBUG_CLIENT_PORT=<your-ide-port-here>
...
```

Just on **Linux environment**, add the `extra_hosts` in your app service as below:

```yaml
...
app:
  image: dersonsena/php-nginx-dev:8.0
  ...
  extra_hosts:
    - "host.docker.internal:host-gateway"
```


**TIP:** if you are using PHPUnit + XDebug to generate coverage, remove the `debug` value and add `coverage` in the `XDEBUG_MODE` env:

```yaml
...
environment:
  - XDEBUG_MODE=develop,coverage
...
```

or you can use the follow command in CLI:

```bash
docker exec -it -e XDEBUG_MODE=coverage "your-container-name" ./vendor/bin/phpunit
```

### NGINX

#### Change Document Root

You can change the nginx document root. If the project's document is `public_html`, for example, you can do:

```yaml
...
environment:
  - NGINX_DOCUMENT_ROOT=/var/www/html/public_html
...
```

#### SSL Certificate

This docker image already have a SSL certificate, but if you want to use a custom SSL certificates to NGINX web server, just create the files in folder in your project, such as `.docker/nginx/`:

- Private Key: `.docker/nginx/certificate.key`
- Certificate: `.docker/nginx/certificate.crt`

and place your certificate and key files there. After this, just map volumes as below:

```yaml
version: '3.5'
services:
  app:
    container_name: project-app
    image: dersonsena/php-nginx-dev:8.0
    volumes:
      - ./:/var/www/html
      - ./.docker/nginx/certs:/etc/nginx/certs
    ports:
      - '80:80'
      - '443:443'
    networks:
      - project-network

networks:
  project-network:
    driver: bridge
```
