#!/bin/sh
set -e

# Base SQL path
BASE_DIR="/app/sql"

# Arguments
SUBDIR="$1"       # required (e.g., templates, custom, backups)
SQL_FILE="$2"     # optional (specific SQL file to run)
FORCE_DB="$3"     # optional (override target DB)

# Validate directory
TARGET_DIR="$BASE_DIR/$SUBDIR"
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR does not exist."
    exit 1
fi

# Determine which SQL files to run
if [ -n "$SQL_FILE" ]; then
    FILES="$TARGET_DIR/$SQL_FILE"
    [ -f "$FILES" ] || { echo "Error: File $FILES not found."; exit 1; }
else
    FILES="$TARGET_DIR"/*.sql
fi

for FILE in $FILES; do
    [ -f "$FILE" ] || continue

    # Determine database target (unless forced)
    TARGET_DB="$FORCE_DB"
    if [ -z "$TARGET_DB" ]; then
        case "$(basename "$FILE")" in
            world_*) TARGET_DB="$WORLD_DB" ;;
            auth_*) TARGET_DB="$AUTH_DB" ;;
            characters_*) TARGET_DB="$CHARACTER_DB" ;;
            *) TARGET_DB="" ;; # Some scripts handle DBs internally
        esac
    fi

    # Prepare a temporary copy with environment substitution
    TMP_SQL=$(mktemp)
    cp "$FILE" "$TMP_SQL"

    VARS=$(grep -oE '\$\{[A-Za-z0-9_]+\}' "$TMP_SQL" | sort -u)
    for var in $VARS; do
        NAME=$(echo "$var" | sed 's/[${}]//g')
        VALUE=$(eval echo "\$$NAME")

        if [ -z "$VALUE" ]; then
            echo "Error: Variable $NAME is not set (required by $FILE)"
            rm -f "$TMP_SQL"
            continue 2
        fi

        # Escape / and & for sed
        ESCAPED=$(printf '%s\n' "$VALUE" | sed 's/[\/&]/\\&/g')
        sed -i "s|\${$NAME}|$ESCAPED|g" "$TMP_SQL"
    done

    echo "Executing $(basename "$FILE") on ${TARGET_DB:-no database}..."

    if [ -n "$TARGET_DB" ]; then
        if ! mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" "$TARGET_DB" < "$TMP_SQL"; then
            echo "Warning: Failed to run $(basename "$FILE") on $TARGET_DB. Skipping..."
            rm -f "$TMP_SQL"
            continue
        fi
    else
        if ! mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" < "$TMP_SQL"; then
            echo "Warning: Failed to run $(basename "$FILE") (no DB). Skipping..."
            rm -f "$TMP_SQL"
            continue
        fi
    fi

    rm -f "$TMP_SQL"
    echo "Done with $(basename "$FILE")."
done