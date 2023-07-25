#!/bin/sh
# Run script to setup environment:
#    - set tool's container names according to an .env

ERR_DOCKER_ENV_NOT_FOUND="Docker environment file is not found."
DOCKER_ENV_FILE=".env"

[ ! -f  "$DOCKER_ENV_FILE" ] && echo "$ERR_DOCKER_ENV_NOT_FOUND" && exit 1
. ./.env > /dev/null

USAGE="$(basename "$0") [-options]

Setup environment.

Options:
    --disable-back : disable to create backup of processed files
    -h             : help"

DISABLE_BACKUP="-i.bak"

while [ $# -gt 0 ]; do
  case $1 in
    --disable-back)
      DISABLE_BACKUP="-i"
      shift
      ;;
    -h)
      echo "$USAGE"
      exit 0
      ;;
    --*)
      echo "Unknown option $1"
      echo "$USAGE"
      exit 1
      ;;
    *)
      shift
      ;;
  esac
done

PHP_CONTAINER_NAME=$COMPOSE_PROJECT_NAME-php-fpm
MYSQL_CONTAINER_NAME=$COMPOSE_PROJECT_NAME-mysql
MARIADB_CONTAINER_NAME=$COMPOSE_PROJECT_NAME-mariadb

find tools -type f  -exec sed "$DISABLE_BACKUP" "s;.*PHP_CONTAINER_NAME=.*;PHP_CONTAINER_NAME=$PHP_CONTAINER_NAME;g" {} \;
find tools -type f  -exec sed "$DISABLE_BACKUP" "s;.*MYSQL_CONTAINER_NAME=.*;MYSQL_CONTAINER_NAME=$MYSQL_CONTAINER_NAME;g" {} \;
find tools -type f  -exec sed "$DISABLE_BACKUP" "s;.*MARIADB_CONTAINER_NAME=.*;MARIADB_CONTAINER_NAME=$MARIADB_CONTAINER_NAME;g" {} \;