#!/bin/sh
set -e

echo "=== Populating databases with base sql ==="
# Increase allowed packet size for large world DB imports
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" \
  -e "SET GLOBAL max_allowed_packet=536870912;"

# Temporary directory for extracted SQL
TMP_DIR="/app/sql"
mkdir -p "$TMP_DIR"

echo "Unzipping base database files..."
unzip -o "$SOURCE_PREFIX/sql/base/auth_04_03_2023.zip" -d "$TMP_DIR"
unzip -o "$SOURCE_PREFIX/sql/base/characters_29_12_2024.zip" -d "$TMP_DIR"
unzip -o "$SOURCE_PREFIX/sql/base/world_04_03_2023.zip" -d "$TMP_DIR"

# Paths
AUTH_SQL_PATH="/app/sql/$AUTH_SQL"
CHAR_SQL_PATH="/app/sql/$CHARACTER_SQL"
WORLD_SQL_PATH="/app/sql/$WORLD_SQL"

echo "Normalizing database names (with backtick support)..."

# Replace only USE and CREATE DATABASE lines for each SQL file
/bin/commands/normalize_sql.sh

echo "Importing databases..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$SERVER_DB_USER" -p"$SERVER_DB_PASSWORD" "$AUTH_DB" < "$AUTH_SQL_PATH"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$SERVER_DB_USER" -p"$SERVER_DB_PASSWORD" "$CHARACTER_DB" < "$CHAR_SQL_PATH"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$SERVER_DB_USER" -p"$SERVER_DB_PASSWORD" "$WORLD_DB" < "$WORLD_SQL_PATH"

echo "=== Database population complete ==="