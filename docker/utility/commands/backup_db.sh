#!/bin/sh
set -e

# Generate timestamped backup directory
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="${SQL_INSTALL_DIR}/backup/${PROJECT_NAME}_${DATE}"
mkdir -p "$BACKUP_DIR"

echo "=== Backing up ${PROJECT_NAME} databases ==="

# Dump all relevant databases
for DB in "$AUTH_DB" "$CHARACTER_DB" "$WORLD_DB"; do
    echo "--- Dumping $DB ---"
    mysqldump \
        -h "$DB_HOST" \
        -P "$DB_PORT" \
        -u "$MYSQL_USERNAME" \
        -p"$MYSQL_PASSWORD" \
        "$DB" > "$BACKUP_DIR/$DB.sql"
done

echo "=== Backups stored in: $BACKUP_DIR ==="
