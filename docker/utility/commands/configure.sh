#!/bin/sh
set -e

echo "=== Configuring ${PROJECT_NAME} authserver and worldserver (overwrite mode) ==="

# Ensure etc directory exists
mkdir -p "$INSTALL_PREFIX/etc"

# Always reset authserver.conf
echo "Resetting authserver.conf..."
cp "$INSTALL_PREFIX/etc/authserver.conf.dist" "$INSTALL_PREFIX/etc/authserver.conf"

sed -i -e "s|^LogsDir =.*|LogsDir = \"$LOGS_DIR_PATH\"|" "$INSTALL_PREFIX/etc/authserver.conf"
sed -i -e "s|^LoginDatabaseInfo =.*|LoginDatabaseInfo = \"$DB_HOST;$DB_PORT;$SERVER_DB_USER;$SERVER_DB_PASSWORD;$AUTH_DB\"|" "$INSTALL_PREFIX/etc/authserver.conf"

# Always reset worldserver.conf
echo "Resetting worldserver.conf..."
cp "$INSTALL_PREFIX/etc/worldserver.conf.dist" "$INSTALL_PREFIX/etc/worldserver.conf"

sed -i -e "s|^DataDir =.*|DataDir = \"$DATA_DIR_PATH\"|" "$INSTALL_PREFIX/etc/worldserver.conf"
sed -i -e "s|^LogsDir =.*|LogsDir = \"$LOGS_DIR_PATH\"|" "$INSTALL_PREFIX/etc/worldserver.conf"

sed -i -e "s|^LoginDatabaseInfo.*|LoginDatabaseInfo = \"$DB_HOST;$DB_PORT;$SERVER_DB_USER;$SERVER_DB_PASSWORD;$AUTH_DB\"|" "$INSTALL_PREFIX/etc/worldserver.conf"
sed -i -e "s|^WorldDatabaseInfo.*|WorldDatabaseInfo = \"$DB_HOST;$DB_PORT;$SERVER_DB_USER;$SERVER_DB_PASSWORD;$WORLD_DB\"|" "$INSTALL_PREFIX/etc/worldserver.conf"
sed -i -e "s|^CharacterDatabaseInfo.*|CharacterDatabaseInfo = \"$DB_HOST;$DB_PORT;$SERVER_DB_USER;$SERVER_DB_PASSWORD;$CHARACTER_DB\"|" "$INSTALL_PREFIX/etc/worldserver.conf"

sed -i -e "s|^GameType =.*|GameType = \"$GAME_TYPE\"|" "$INSTALL_PREFIX/etc/worldserver.conf"
sed -i -e "s|^RealmZone =.*|RealmZone = \"$REALM_ZONE\"|" "$INSTALL_PREFIX/etc/worldserver.conf"
sed -i -e "s|^Motd =.*|Motd = \"$MOTD_MSG\"|" "$INSTALL_PREFIX/etc/worldserver.conf"

sed -i -e "s|^Ra.Enable =.*|Ra.Enable = \"$RA_ENABLE\"|" "$INSTALL_PREFIX/etc/worldserver.conf"
sed -i -e "s|^SOAP.Enabled =.*|SOAP.Enabled = \"$SOAP_ENABLE\"|" "$INSTALL_PREFIX/etc/worldserver.conf"
sed -i -e "s|^SOAP.IP =.*|SOAP.IP = \"$SOAP_IP\"|" "$INSTALL_PREFIX/etc/worldserver.conf"

sed -i -e "s|^Console.Enable =.*|Console.Enable = \"$CONSOLE\"|" "$INSTALL_PREFIX/etc/worldserver.conf"

echo "=== Configuration updated successfully ==="