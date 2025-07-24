#!/bin/sh
set -e

echo "=== Updating auth database: $AUTH_DB... ==="

# --- Clean up old accounts ---
echo "Cleaning up old users..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" "$AUTH_DB" -e "DELETE FROM account;"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" "$AUTH_DB" -e "DELETE FROM account_access;"

# --- Add admin account ---
echo "Adding admin account (username: admin)..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" "$AUTH_DB" <<EOF
INSERT INTO account (id, username, sha_pass_hash) 
VALUES (1, 'ADMIN', '8301316D0D8448A34FA6D0C6BF1CBFA2B4A1A93A');
INSERT INTO account_access (id, gmlevel, RealmID) 
VALUES (1, 3, -1);
EOF

# --- Update realmlist ---
echo "Updating realmlist..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" "$AUTH_DB" <<EOF
DELETE FROM realmlist;

INSERT INTO realmlist (
    id, name, project_shortname, address, port, icon, color, timezone, 
    allowedSecurityLevel, population, gamebuild, flag, 
    project_hidden, project_enabled, project_dbname, project_dbworld, 
    project_dbarchive, project_rates_min, project_rates_max, 
    project_transfer_level_max, project_transfer_items, 
    project_transfer_skills_spells, project_transfer_glyphs, 
    project_transfer_achievements, project_server_same, 
    project_server_settings, project_server_remote_path, 
    project_accounts_detach, project_setskills_value_max, 
    project_chat_enabled, project_statistics_enabled
) VALUES (
    1, '$REALM_NAME', '$REALM_NAME', '$REALM_ADDRESS', '$REALM_PORT',
    $REALM_ICON, $REALM_COLOR, $REALM_TIMEZONE, 
    $REALM_SECURITY, $REALM_POP, $REALM_BUILD, $REALM_FLAG, 
    0, 1, '', '', '', 
    0, 0, 80, 'IGNORE', 'IGNORE', 'IGNORE', 'IGNORE', 
    0, '0', '0', 1, 0, 0, 0
);
EOF

# --- Cleanup temp SQL files ---
echo "Cleaning up temp SQL files..."
rm -f /tmp/*.sql || true

echo "=== Auth database update complete. ==="