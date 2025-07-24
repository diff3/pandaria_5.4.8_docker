#!/bin/sh
set -e

echo "=== Running custom SQL scripts ==="

for sql_file in "$CUSTOM_SQL_DIR"/*.sql; do
    [ -f "$sql_file" ] || continue

    # Determine database based on file prefix
    case "$(basename "$sql_file")" in
        world_*) TARGET_DB="$WORLD_DB" ;;
        auth_*) TARGET_DB="$AUTH_DB" ;;
        characters_*) TARGET_DB="$CHARACTER_DB" ;;
        *) echo "Skipping $sql_file (unknown target DB)"; continue ;;
    esac

    echo "Applying $sql_file on $TARGET_DB..."
    if ! mysql --force -h "$DB_HOST" -P "$DB_PORT" \
        -u "$SERVER_DB_USER" -p"$SERVER_DB_PASSWORD" "$TARGET_DB" < "$sql_file"; then
        echo "Warning: Failed to apply $sql_file (continuing...)"
    else
        echo "Applied: $sql_file successfully."
    fi
done

echo "=== Custom SQL scripts complete ==="