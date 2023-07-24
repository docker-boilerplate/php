#!/bin/sh
# Read db options in docker.env and restore sql db dump into default database or passed in the options

ERR_DOCKER_ENV_NOT_FOUND="Docker environment file is not found."
DOCKER_ENV_FILE="../.docker/.env"

[ ! -f  "$DOCKER_ENV_FILE" ] && echo "$ERR_DOCKER_ENV_NOT_FOUND" && exit 1
. ../.docker/.env > /dev/null

USAGE="$(basename "$0") --dump=filename [--db=db_name] [-y] [-h]

Restore mysql db dump.

Options:
    --dump=filename  : path to file with dump to restore
    --db=db_name  : db name to dump restores in
    -h  : show this help
    -y  : answer 'yes' to confirmation question"

ERR_DB_VAR_MISSED="The %s db variables doesn't sets in the Docker environment file: %s.\n" 

[ -z "$MYSQL_USER" ] && printf "$ERR_DB_VAR_MISSED" "MY_SQL_USER" "$DOCKER_ENV_FILE" && exit 1

[ -z "$MYSQL_PASSWORD" ] && printf "$ERR_DB_VAR_MISSED" "MYSQL_PASSWORD" "$DOCKER_ENV_FILE" && exit 1 

DATABASE=""
DUMP=""
CONFIRM=0

die() { echo "$USAGE"; echo "$*" >&2; exit 2; } 
needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; }

while getopts hy-: OPT; do
  if [ "$OPT" = "-" ]; then  
    OPT="${OPTARG%%=*}"     
    OPTARG="${OPTARG#"$OPT"}"  
    OPTARG="${OPTARG#=}"      
  fi
  case "$OPT" in
    h )    echo "$USAGE" ;exit 0 ;;
    y )    CONFIRM=1    ;;
    dump ) needs_arg; DUMP="$OPTARG" ;;
    db )   needs_arg; DATABASE="$OPTARG" ;;
    ??* )  die "Illegal option --$OPT" ;; 
    ? )    echo "$USAGE" >&2; exit 2 ;;  
  esac
done
shift $((OPTIND-1))


if [ -z "$DATABASE" ]; then
DATABASE=$MYSQL_DATABASE
fi
[ -z "$DATABASE" ] && printf "$ERR_DB_VAR_MISSED" "MYSQL_DATABASE" "$DOCKER_ENV_FILE" && exit 1

[ -z "$DUMP" ] && echo "Please pass sql dump file to restore" && echo "$USAGE" && exit 1 

[ ! -f "$DUMP" ] && echo "The passed dump is not a file." && exit 1 

if [ $CONFIRM = "0" ]; then
  MES_CONFIRM="This script will restore the $DUMP dump into default database: '$DATABASE'
The '$DATABASE' WILL BE OVERWRITTEN AND ALL DATA WILL BE LOST!
If it need to restore into a new database, please pass database name in -db param
Are you sure to continue? (Write 'y' or 'yes')"
  echo "$MES_CONFIRM"
  read -r ANSWER
  [ "$ANSWER" != 'yes' ] && [ "$ANSWER" != 'y' ]  && exit 0;
fi

MYSQL_CONTAINER_NAME=bar-mysql
echo "Start to restore $DUMP into $DATABASE:"

CREATE_DB="CREATE DATABASE IF NOT EXISTS $DATABASE;"
docker exec -i $MYSQL_CONTAINER_NAME sh -c "exec mysql -uroot -p\"\$MYSQL_ROOT_PASSWORD\" -e \"$CREATE_DB\""

GRANT_USER_TO_DB="GRANT ALL ON \\\`$DATABASE\\\`.* TO \\\`$MYSQL_USER\\\`@\\\`%\\\` ;"
docker exec -i $MYSQL_CONTAINER_NAME sh -c "exec mysql -uroot -p\"\$MYSQL_ROOT_PASSWORD\" -e \"$GRANT_USER_TO_DB\""

if (dpkg -s pv | grep -q Status) >/dev/null 2>&1
  then
    pv -pert "$DUMP" | docker exec -i $MYSQL_CONTAINER_NAME sh -c "exec mysql -uroot -p\"$MYSQL_ROOT_PASSWORD\" $DATABASE"
  else
    docker exec -i $MYSQL_CONTAINER_NAME sh -c "exec mysql -uroot -p\"$MYSQL_ROOT_PASSWORD\" $DATABASE" < "$DUMP"
fi
