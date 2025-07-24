#!/bin/sh
set -e

echo "=== Updating databases ==="



# --- Download and import latest world dump ---
if [ ! -f "$WORLD_DB_ZIP" ]; then
    echo "Downloading latest world database..."
    wget --progress=bar:force:noscroll "$WORLD_DB_URL" -O "$WORLD_DB_ZIP"
fi

echo "Extracting world database..."
unzip -o "$WORLD_DB_ZIP" -d /app/sql

# Normalize world SQL (replaces DB names)
/bin/commands/normalize_sql.sh

mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" \
  -e "SET GLOBAL max_allowed_packet=536870912;"

echo "Importing world update into $WORLD_DB..."

mysql -h "$DB_HOST" -P "$DB_PORT" -u "$SERVER_DB_USER" -p"$SERVER_DB_PASSWORD" "$WORLD_DB" < "$WORLD_SQL_UPDATE"

echo "World database update complete."

# --- Apply incremental updates ---
echo "Applying incremental SQL updates..."

upload_sql_files() {
    local directory="$1"
    local database="$2"  # AUTH_DB, CHARACTER_DB, or WORLD_DB
    local base_date="$3" # YYYY_MM_DD from world-dump

    if [ ! -d "$directory" ]; then
        echo "Directory $directory does not exist, skipping."
        return 0
    fi

    local db_name
    db_name=$(eval echo "\$$database")

    if [ -z "$db_name" ]; then
        echo "Database variable $database is not set, skipping."
        return 0
    fi

    echo "Uploading SQL files from $directory to $db_name (after $base_date)..."

    for sql_file in "$directory"/*.sql; do
        [ -f "$sql_file" ] || continue

        file_date=$(basename "$sql_file" | cut -d'_' -f1-3)

        if [ "$file_date" \< "$base_date" ] || [ "$file_date" = "$base_date" ]; then
            echo "Skipping $sql_file (older or equal to dump date)"
            continue
        fi

        if ! mysql --force -h "$DB_HOST" -P "$DB_PORT" -u "$SERVER_DB_USER" -p"$SERVER_DB_PASSWORD" "$db_name" < "$sql_file"; then
            echo "Warning: Failed to import $sql_file (continuing...)"
        fi
    done

    echo "Updates for $db_name complete."
}

# --- Apply SQL fixes (before world dump) ---
/bin/commands/run_sql_fixes.sh

upload_sql_files "$SOURCE_PREFIX/sql/updates/auth" "AUTH_DB"
upload_sql_files "$SOURCE_PREFIX/sql/updates/characters" "CHARACTER_DB"
upload_sql_files "$SOURCE_PREFIX/sql/updates/world" "WORLD_DB"
# upload_sql_files "$SOURCE_PREFIX/sql/updates/world/battlepay" "WORLD_DB"
# upload_sql_files "$SOURCE_PREFIX/sql/updates/world/localization/enUS" "WORLD_DB"
# upload_sql_files "$SOURCE_PREFIX/sql/updates/world/localization/ruRU" "WORLD_DB"

echo "=== Database update complete ==="