#!/bin/sh
set -e

# Load environment (if not already loaded by container)
if [ -f "$(dirname "$0")/.env" ]; then
    # shellcheck disable=SC1091
    . "$(dirname "$0")/.env"
fi

# Arguments
SUBDIR="$1"       # required (relative to /app/sql/, e.g., install, fixes, custom, templates)
SQL_FILE="$2"     # optional (specific SQL file to run)
FORCE_DB="$3"     # optional (explicit DB override: AUTH_DB, WORLD_DB, CHARACTER_DB)

BASE_PATH="/app/sql"
TARGET_DIR="$BASE_PATH/$SUBDIR"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR does not exist."
    exit 1
fi

# Decide which files to process
if [ -n "$SQL_FILE" ]; then
    FILES="$TARGET_DIR/$SQL_FILE"
    [ -f "$FILES" ] || { echo "Error: File $FILES not found."; exit 1; }
else
    FILES="$TARGET_DIR"/*.sql
fi

for FILE in $FILES; do
    [ -f "$FILE" ] || continue

    # Determine target DB if not overridden
    TARGET_DB="$FORCE_DB"
    if [ -z "$TARGET_DB" ]; then
        case "$(basename "$FILE")" in
            world_*) TARGET_DB="$WORLD_DB" ;;
            auth_*) TARGET_DB="$AUTH_DB" ;;
            characters_*) TARGET_DB="$CHARACTER_DB" ;;
            *) TARGET_DB="" ;; # Will run without selecting a DB
        esac
    fi

    # Substitute environment variables into temp file
    TMP_SQL=$(mktemp)
    cp "$FILE" "$TMP_SQL"

    VARS=$(grep -oE '\$\{[A-Za-z0-9_]+\}' "$TMP_SQL" | sort -u)
    for var in $VARS; do
        NAME=$(echo "$var" | sed 's/[${}]//g')
        VALUE=$(eval echo "\$$NAME")

        if [ -z "$VALUE" ]; then
            echo "Error: Variable $NAME is not set (required by $(basename "$FILE"))"
            rm -f "$TMP_SQL"
            continue 2
        fi

        ESCAPED=$(printf '%s\n' "$VALUE" | sed 's/[\/&]/\\&/g')
        sed -i "s|\${$NAME}|$ESCAPED|g" "$TMP_SQL"
    done

    echo "Executing $(basename "$FILE") on ${TARGET_DB:-no database}..."

    # Run MySQL with --force so the file continues even if some statements fail
    if [ -n "$TARGET_DB" ]; then
        mysql --force -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" "$TARGET_DB" < "$TMP_SQL"
    else
        mysql --force -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" < "$TMP_SQL"
    fi

    # MySQL will still return error code if any statement fails, but we log a warning and continue
    if [ $? -ne 0 ]; then
        echo "Warning: Errors occurred while running $(basename "$FILE"). Continuing..."
    fi

    rm -f "$TMP_SQL"
    echo "Done with $(basename "$FILE")."
done
