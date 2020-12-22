#!/bin/sh
set -e

host="user_db"

until PGPASSWORD=postgres psql -h "$host" -U "postgres" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing command"

$@
