# PHP 7.4 FPM + NGINX Dev Enviroment

Image composition and versions below:

- PHP FPM 7.4
- XDebug 3.0.2
- NGINX 1.18.0-r13
- Composer 2.0.9
- Git 2.30.1-r0

## Docker Compose

### Minimal to use

```bash
docker run -d --name project-app -v "$PWD":/var/www/html -p 80:80 -p 443:443 dersonsena/php-nginx-dev
```

### Minimal to use with Docker Compose

The snipet below show the **minimal setup**:

```yaml
version: '3.5'
services:
  app:
    container_name: project-app
    image: dersonsena/php-nginx-dev
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

> **IMPORTANT**: You must be a `/public` because this folder is the Nginx Document Root. If your project doesn't have it, you can create a symbolic link: `ln -fs ./your-document-root ./public`

### PHP

You can custumize some php ini params. The posibles variables and their default values are shown below:

```yaml
version: '3.5'
services:
  app:
    container_name: project-app
    image: dersonsena/php-nginx-dev
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

If you want use a custom `php.ini` file, just create one in your project, such as `.docker/php/php.ini`, and map volume like below:

```yaml
...
volumes:
  - ./:/var/www/html
  - ./.docker/php:/usr/local/etc/php
...
```

> **TIP**: to make your life easier you can use the original php.ini file placed in root level of this repository.

### XDebug

You can custumize some xdebug params. The posibles variables and their default values are shown below:

```yaml
version: '3.5'
services:
  app:
    container_name: project-app
    image: dersonsena/php-nginx-dev
    volumes:
      - ./:/var/www/html
    ports:
      - '80:80'
      - '443:443'
    environment:
      - XDEBUG_MODE=debug
      - XDEBUG_START_WITH_REQUEST=yes
      - XDEBUG_DISCOVER_CLIENT_HOST=false
      - XDEBUG_CLIENT_HOST=host.docker.internal
      - XDEBUG_CLIENT_PORT=9000
      - XDEBUG_MAX_NESTING_LEVEL=1500
      - XDEBUG_IDE_KEY=PHPSTORM
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
  - XDEBUG_DISCOVER_CLIENT_HOST=false
  - XDEBUG_CLIENT_PORT=<your-ide-port-here>
...
```

### SSL Certificate to NGINX

This docker image already have a SSL certificate, but if you want to use a custom SSL certificates to NGINX web server, just create thes files in folder in your project, such as `.docker/nginx/`:

- Private Key: `.docker/nginx/certificate.key`
- Certificate: `.docker/nginx/certificate.crt`

and place your certificate and key files there. After this, just map volumes as below:

```yaml
version: '3.5'
services:
  app:
    container_name: project-app
    image: dersonsena/php-nginx-dev
    volumes:
      - ./:/var/www/html
      - ./docker/nginx:/etc/nginx/certs
    ports:
      - '80:80'
      - '443:443'
    networks:
      - project-network

networks:
  project-network:
    driver: bridge
```
