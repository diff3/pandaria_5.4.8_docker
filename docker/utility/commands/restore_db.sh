#!/bin/sh
set -e

echo "=== Restoring ${PROJECT_NAME} databases ==="

BACKUP_DIR="/app/sql/backup"
DB_HOST="${DB_HOST:?DB_HOST not set}"
DB_PORT="${DB_PORT:?DB_PORT not set}"
ROOT_USER="${MYSQL_USERNAME:?MYSQL_USERNAME not set}"
ROOT_PASS="${MYSQL_PASSWORD:?MYSQL_PASSWORD not set}"

# Use provided backup folder or auto-detect latest
if [ -n "$BACKUP" ]; then
    BACKUP_PATH="$BACKUP_DIR/$BACKUP"
else
    LATEST_BACKUP=$(ls -1 "$BACKUP_DIR" | sort | tail -n 1)
    BACKUP_PATH="$BACKUP_DIR/$LATEST_BACKUP"
fi

if [ ! -d "$BACKUP_PATH" ]; then
    echo "Backup directory $BACKUP_PATH not found."
    exit 1
fi

echo "Using backup: $BACKUP_PATH"

# Function to drop and recreate database
reset_db() {
    local db="$1"
    echo "Resetting database $db..."
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$ROOT_USER" -p"$ROOT_PASS" -e "DROP DATABASE IF EXISTS \`$db\`; CREATE DATABASE \`$db\` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
}

# Restore all three databases
for DB in "$AUTH_DB" "$CHARACTER_DB" "$WORLD_DB"; do
    DUMP_FILE="$BACKUP_PATH/${DB}.sql"
    reset_db "$DB"
    if [ -f "$DUMP_FILE" ]; then
        echo "Restoring $DB from $DUMP_FILE..."
        mysql -h "$DB_HOST" -P "$DB_PORT" -u "$ROOT_USER" -p"$ROOT_PASS" "$DB" < "$DUMP_FILE"
        echo "Restored $DB successfully."
    else
        echo "Warning: No dump file for $DB at $DUMP_FILE"
    fi
done

echo "=== Database restore complete ==="