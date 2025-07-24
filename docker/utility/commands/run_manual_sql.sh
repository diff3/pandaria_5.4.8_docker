#!/bin/sh
set -e

# Load environment variables
SQL_DIR="/app/custom_sql/misc"

if [ -n "$1" ]; then
    FILE="$SQL_DIR/$1"
    if [ ! -f "$FILE" ]; then
        echo "File $FILE not found."
        exit 1
    fi
    SQL_FILES="$FILE"
else
    SQL_FILES="$SQL_DIR"/*.sql
fi

for sql_file in $SQL_FILES; do
    [ -f "$sql_file" ] || continue

    # Determine target DB from filename prefix
    case "$(basename "$sql_file")" in
        world_*) TARGET_DB="$WORLD_DB" ;;
        auth_*) TARGET_DB="$AUTH_DB" ;;
        characters_*) TARGET_DB="$CHARACTER_DB" ;;
        *) echo "Skipping $sql_file (unknown DB target)"; continue ;;
    esac

    echo "Applying $sql_file on $TARGET_DB..."
    if ! mysql --force -h "$DB_HOST" -P "$DB_PORT" \
        -u "$SERVER_DB_USER" -p"$SERVER_DB_PASSWORD" \
        "$TARGET_DB" < "$sql_file"; then
        echo "Warning: Failed to apply $sql_file (continuing...)"
    else
        echo "Applied: $sql_file successfully."
    fi
done