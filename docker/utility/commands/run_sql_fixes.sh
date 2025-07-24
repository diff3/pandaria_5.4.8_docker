#!/bin/sh
set -e

echo "=== Running SQL fixes (forcing recreate of tables) ==="

for sql_file in "$SQL_FIXES_DIR"/*.sql; do
    [ -f "$sql_file" ] || continue

    # Bestäm databas från filnamnet
    case "$(basename "$sql_file")" in
        world_*) TARGET_DB="$WORLD_DB" ;;
        auth_*) TARGET_DB="$AUTH_DB" ;;
        characters_*) TARGET_DB="$CHARACTER_DB" ;;
        *) echo "Skipping $sql_file (unknown target DB)"; continue ;;
    esac

    echo "Processing $sql_file on $TARGET_DB..."

    # Hämta tabellnamnet från första CREATE TABLE i filen
    TABLE_NAME=$(grep -i -m1 'CREATE TABLE' "$sql_file" | sed -E 's/.*`([^`]*)`.*/\1/')

    if [ -n "$TABLE_NAME" ]; then
        echo "Dropping existing table $TABLE_NAME (if exists)..."
        mysql -h "$DB_HOST" -P "$DB_PORT" -u "$SERVER_DB_USER" -p"$SERVER_DB_PASSWORD" "$TARGET_DB" \
            -e "DROP TABLE IF EXISTS \`$TABLE_NAME\`;"
    fi

    # Kör SQL-filen och tvinga igenom trots varningar
    echo "Applying $sql_file..."
    if ! mysql --force -h "$DB_HOST" -P "$DB_PORT" -u "$SERVER_DB_USER" -p"$SERVER_DB_PASSWORD" "$TARGET_DB" < "$sql_file"; then
        echo "Warning: Failed to apply $sql_file (continuing...)"
    else
        echo "Applied: $sql_file successfully."
    fi
done

echo "=== SQL fixes complete ==="