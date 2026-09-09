#!/bin/sh
# Run by the MariaDB entrypoint the first time the server starts, before it
# accepts connections from outside the container.
#
# This is a shell script rather than a plain .sql file dropped into
# /docker-entrypoint-initdb.d/ because sql/load-data.sql uses
# LOAD DATA LOCAL INFILE with paths relative to the repository root. The
# client therefore needs both --local-infile and the right working
# directory, and the entrypoint's own .sql handling gives us neither.
set -eu

cd /openflights

mariadb_root() {
    mariadb --user=root --password="${MARIADB_ROOT_PASSWORD}" "$@"
}

echo "openflights: creating schema"
mariadb_root < sql/create.sql

echo "openflights: loading data"
mariadb_root --local-infile=1 < sql/load-data.sql

# Present once sql/verify.sql is merged; skipped until then.
if [ -f sql/verify.sql ]; then
    echo "openflights: verifying"
    mariadb_root < sql/verify.sql
fi

echo "openflights: ready"
