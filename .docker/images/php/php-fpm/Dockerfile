ARG PHP_VERSION
ARG COMPOSER_VERSION
FROM composer:${COMPOSER_VERSION} AS composer
FROM php:${PHP_VERSION}

ARG GROUP_ID_HOST
ARG USER_ID_HOST
ARG XDEBUG_IDE_KEY
ARG XDEBUG_VERSION

RUN apt update

# xdebug
RUN pecl install xdebug$XDEBUG_VERSION \
    && docker-php-ext-enable xdebug
COPY ./images/php/php-fpm/conf.d/xdebug.ini $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini
RUN sed -i "s;__IDE_KEY;$XDEBUG_IDE_KEY;" $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini

## mysqli extension
RUN docker-php-ext-install mysqli \
    && docker-php-ext-enable mysqli

## pdo extension
#RUN docker-php-ext-install pdo pdo_mysql
#
## gd graphic library extension
#RUN apt install zip -y \
#    && apt install git -y \
#    && apt install zlib1g-dev -y \
#    && apt install libpng-dev -y \
#    && apt install libjpeg-dev -y \
#    && docker-php-ext-install gd
#
## intl internalization functions extension
#RUN apt install -y libicu-dev \
#    && docker-php-ext-configure intl \
#    && docker-php-ext-install intl

#ENV PHP_MEMORY_LIMIT=512M

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN usermod -u $USER_ID_HOST www-data && groupmod -g $GROUP_ID_HOST www-data
COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /var/www