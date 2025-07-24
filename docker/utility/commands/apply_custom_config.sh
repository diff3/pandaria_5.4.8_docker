#!/bin/sh
set -e


 # Där worldserver.conf och authserver.conf ligger

# Om en specifik fil anges, kör bara den
if [ -n "$1" ]; then
    FILES="$CUSTOM_DIR/$1"
else
    FILES="$CUSTOM_DIR"/*.conf
fi

for FILE in $FILES; do
    [ -f "$FILE" ] || continue
    echo "Applying custom config from: $FILE"

    # Läs varje rad och uppdatera motsvarande setting i worldserver.conf eller authserver.conf
    while IFS= read -r line; do
        # Hoppa över tomma rader eller kommentarer
        [ -z "$line" ] && continue
        echo "$line" | grep -qE '^\s*#' && continue

        KEY=$(echo "$line" | cut -d'=' -f1 | xargs)
        VALUE=$(echo "$line" | cut -d'=' -f2- | xargs)

        # Hitta vilken fil som ska uppdateras (authserver eller worldserver)
        if grep -q "^$KEY" "$ETC_DIR_PATH/authserver.conf" 2>/dev/null; then
            sed -i "s|^$KEY.*|$KEY = $VALUE|" "$ETC_DIR_PATH/authserver.conf"
            echo "  Updated authserver.conf: $KEY = $VALUE"
        elif grep -q "^$KEY" "$ETC_DIR_PATH/worldserver.conf" 2>/dev/null; then
            sed -i "s|^$KEY.*|$KEY = $VALUE|" "$ETC_DIR_PATH/worldserver.conf"
            echo "  Updated worldserver.conf: $KEY = $VALUE"
        else
            echo "  Warning: $KEY not found in any config file"
        fi
    done < "$FILE"
done

echo "Custom config applied."
