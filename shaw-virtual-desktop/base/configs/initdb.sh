#!/bin/bash

for varname in POSTGRES_HOSTNAME POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD GUACAMOLE_ADMIN_PASSWORD; do
    if [[ -z ${!varname} ]]; then
        echo "ERROR: missing required variable \"$varname\"" >&2
        exit 1
    else
        echo "HAVE: ${varname}=${!varname}"
    fi
done

export PGDATABASE=$POSTGRES_DB
export PGUSER=$POSTGRES_USER
export PGPASSWORD=$POSTGRES_PASSWORD
export PGHOST=${POSTGRES_HOSTNAME}

while ! psql -c 'select 1' > /dev/null 2>&1; do
    echo "waiting for database..."
    sleep 1
done

set -o errexit
set -x

password_salt="$(dd if=/dev/urandom bs=1 count=32 2> /dev/null | sha256sum | cut -f1 -d' ')"
password_salt=${password_salt^^}
password_hash="$(echo -n "${GUACAMOLE_ADMIN_PASSWORD}${password_salt}" | sha256sum | cut -f1 -d' ')"
password_hash=${password_hash^^}

if ! psql -c 'select 1 from guacamole_user' > /dev/null 2>&1; then
    echo "initializing guacamole database"
    sed \
        -e "s/@GUACAMOLE_PASSWORD_HASH@/${password_hash}/" \
        -e "s/@GUACAMOLE_PASSWORD_SALT@/${password_salt}/" \
        /initdb/initdb.sql | psql --echo-all
else
    echo "skipping guacamole database initialization (already initialized)"
fi
