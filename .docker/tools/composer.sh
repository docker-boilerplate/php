#!/bin/sh

PHP_CONTAINER_NAME=foo-php-fpm
echo "$*"
docker exec $PHP_CONTAINER_NAME composer $*