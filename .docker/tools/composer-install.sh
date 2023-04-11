#!/bin/sh

PHP_CONTAINER_NAME=bar-php-fpm
docker exec $PHP_CONTAINER_NAME composer install