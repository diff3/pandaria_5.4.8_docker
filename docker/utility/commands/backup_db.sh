#!/bin/sh
set -e

echo "=== Backing up Pandaria databases ==="

DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/backup/$DATE"
mkdir -p "$BACKUP_DIR"

for DB in "$AUTH_DB" "$CHARACTER_DB" "$WORLD_DB"; do
    echo "--- Dumping $DB ---"
    mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" "$DB" > "$BACKUP_DIR/$DB.sql"
done

echo "Backups stored in $BACKUP_DIR"