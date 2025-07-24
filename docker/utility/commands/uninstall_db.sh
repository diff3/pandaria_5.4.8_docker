#!/bin/sh
set -e

echo "=== Uninstalling Pandaria databases and user ==="

# Load env variables
DB_HOST="${DB_HOST:?DB_HOST not set}"
DB_PORT="${DB_PORT:?DB_PORT not set}"
ROOT_USER="${MYSQL_USERNAME:?MYSQL_USERNAME not set}"
ROOT_PASS="${MYSQL_PASSWORD:?MYSQL_PASSWORD not set}"
SERVER_USER="${SERVER_DB_USER:?SERVER_DB_USER not set}"
AUTH_DB="${AUTH_DB:?AUTH_DB not set}"
CHAR_DB="${CHARACTER_DB:?CHARACTER_DB not set}"
WORLD_DB="${WORLD_DB:?WORLD_DB not set}"

# Drop databases and user
echo "Dropping databases: $AUTH_DB, $CHAR_DB, $WORLD_DB"
echo "Dropping user: $SERVER_USER"

mysql -h "$DB_HOST" -P "$DB_PORT" -u "$ROOT_USER" -p"$ROOT_PASS" -e "
DROP DATABASE IF EXISTS \`$AUTH_DB\`;
DROP DATABASE IF EXISTS \`$CHAR_DB\`;
DROP DATABASE IF EXISTS \`$WORLD_DB\`;
DROP USER IF EXISTS '$SERVER_USER'@'%';
FLUSH PRIVILEGES;
"

echo "=== Database and user cleanup complete ==="