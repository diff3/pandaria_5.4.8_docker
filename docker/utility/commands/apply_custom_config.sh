#!/bin/sh
set -e

# Apply custom configuration files to authserver.conf and worldserver.conf
# Uses CUSTOM_DIR (for input) and ETC_DIR_PATH (for target configs) from .env

echo "=== Applying custom configs to project ${PROJECT_NAME} ==="

if [ -z "$CUSTOM_DIR" ] || [ -z "$ETC_DIR_PATH" ]; then
    echo "Error: CUSTOM_DIR or ETC_DIR_PATH is not set. Check your .env file."
    exit 1
fi

# If a specific config file is provided as argument, only process that file
if [ -n "$1" ]; then
    FILES="$CUSTOM_DIR/$1"
else
    FILES="$CUSTOM_DIR"/*.conf
fi

for FILE in $FILES; do
    [ -f "$FILE" ] || continue
    echo "Applying custom config from: $FILE"

    while IFS= read -r LINE; do
        # Skip empty lines and comments
        [ -z "$LINE" ] && continue
        echo "$LINE" | grep -qE '^\s*#' && continue

        KEY=$(echo "$LINE" | cut -d'=' -f1 | xargs)
        VALUE=$(echo "$LINE" | cut -d'=' -f2- | xargs)

        # Update value in target config files (authserver.conf & worldserver.conf)
        for TARGET in "$ETC_DIR_PATH/authserver.conf" "$ETC_DIR_PATH/worldserver.conf"; do
            if grep -q "^$KEY" "$TARGET"; then
                sed -i "s|^$KEY.*|$KEY = $VALUE|" "$TARGET"
            else
                echo "$KEY = $VALUE" >> "$TARGET"
            fi
        done
    done < "$FILE"
done

echo "=== Custom configs applied successfully ==="
