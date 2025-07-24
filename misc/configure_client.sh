#!/bin/sh
set -e

WOW_PATH=$1
WOW_LOCALE="$2"
REALM_ADDRESS="$3"

REALMLIST_PATH=$WOW_PATH/Data/$WOW_LOCALE/realmlist.wtf
CONFIG_PATH="$WOW_PATH/WTF/Config.wtf"

echo "Configuring WoW client at: $WOW_PATH"
echo "Locale: $WOW_LOCALE"
echo "Realm Address: $REALM_ADDRESS"

# Ensure directories exist
mkdir -p "$(dirname "$REALMLIST_PATH")"
mkdir -p "$(dirname "$CONFIG_PATH")"

# Backup existing files if they exist
[ -f "$REALMLIST_PATH" ] && cp "$REALMLIST_PATH" "$REALMLIST_PATH.bak"
[ -f "$CONFIG_PATH" ] && cp "$CONFIG_PATH" "$CONFIG_PATH.bak"

# Overwrite realmlist.wtf
echo "SET realmlist $REALM_ADDRESS" > "$REALMLIST_PATH"
echo "Updated $REALMLIST_PATH"

# Update or append SET realmlist in Config.wtf
if [ -f "$CONFIG_PATH" ]; then
    # Replace if line exists, otherwise append
    if grep -q '^SET realmlist ' "$CONFIG_PATH"; then
        sed -i "s|^SET realmlist .*|SET realmlist \"$REALM_ADDRESS\"|" "$CONFIG_PATH"
    else
        echo "SET realmlist \"$REALM_ADDRESS\"" >> "$CONFIG_PATH"
    fi
else
    echo "SET realmlist \"$REALM_ADDRESS\"" > "$CONFIG_PATH"
fi

echo "Updated $CONFIG_PATH"
echo "WoW client configuration complete."
