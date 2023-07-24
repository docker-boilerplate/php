#!/bin/sh

PHP_CONTAINER_NAME=bar-php-fpm
echo "$*"
docker exec $PHP_CONTAINER_NAME composer $*