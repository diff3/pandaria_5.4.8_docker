#!/bin/sh
set -e

echo "=== Initializing MySQL databases and user ==="

echo "Removing old databases and user..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "DROP DATABASE IF EXISTS $AUTH_DB;"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "DROP DATABASE IF EXISTS $WORLD_DB;"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "DROP DATABASE IF EXISTS $CHARACTER_DB;"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "DROP USER IF EXISTS '$SERVER_DB_USER'@'%';"

echo "Creating new databases..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "CREATE DATABASE $AUTH_DB;"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "CREATE DATABASE $WORLD_DB;"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "CREATE DATABASE $CHARACTER_DB;"

echo "Creating user and granting privileges..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "CREATE USER '$SERVER_DB_USER'@'%' IDENTIFIED BY '$SERVER_DB_PASSWORD';"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "GRANT ALL PRIVILEGES ON $AUTH_DB.* TO '$SERVER_DB_USER'@'%';"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "GRANT ALL PRIVILEGES ON $WORLD_DB.* TO '$SERVER_DB_USER'@'%';"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "GRANT ALL PRIVILEGES ON $CHARACTER_DB.* TO '$SERVER_DB_USER'@'%';"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "FLUSH PRIVILEGES;"

echo "=== Database initialization complete ==="