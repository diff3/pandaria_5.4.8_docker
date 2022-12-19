#!/bin/sh

echo "Starting Initialization of CMaNGOS DB..."

echo "Creating databases"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "create database $CHAR_DB_NAME;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "create database $LOGS_DB_NAME;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "create database $WORLD_DB_NAME;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "create database $REALM_DB_NAME;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "create user '$SERVER_DB_USER'@'$SERVER_DB_USERIP' identified by '$SERVER_DB_PWD';"

mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "grant all privileges on $CHAR_DB_NAME.* to '$SERVER_DB_USER'@'$SERVER_DB_USERIP';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "grant all privileges on $LOGS_DB_NAME.* to '$SERVER_DB_USER'@'$SERVER_DB_USERIP';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "grant all privileges on $WORLD_DB_NAME.* to '$SERVER_DB_USER'@'$SERVER_DB_USERIP';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "grant all privileges on $REALM_DB_NAME.* to '$SERVER_DB_USER'@'$SERVER_DB_USERIP';"

echo "Adding base data to databases"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $REALM_DB_NAME < /opt/mangos-tbc/sql/base/realmd.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $WORLD_DB_NAME < /opt/mangos-tbc/sql/base/mangos.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $CHAR_DB_NAME < /opt/mangos-tbc/sql/base/characters.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $LOGS_DB_NAME < /opt/mangos-tbc/sql/base/logs.sql

echo "Configure users, and removal"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $REALM_DB_NAME -e "UPDATE account SET gmlevel = '4', locked = '1' WHERE id = '1' LIMIT 1;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $REALM_DB_NAME -e "DELETE FROM account WHERE id = '2' LIMIT 1;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $REALM_DB_NAME -e "DELETE FROM account WHERE id = '3' LIMIT 1;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $REALM_DB_NAME -e "DELETE FROM account WHERE id = '4' LIMIT 1;"

echo "Add user"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $REALM_DB_NAME -e "INSERT INTO account (username, gmlevel, v, s, expansion, locale) VALUES ('MAPE', 4, '598439E55FF93613E12E89B23A1348D38BDCEA98C77347C2A84EE1CC210C3BDE', 'B09701BDE2AAEF7E068438E831BAA8A2FF8301338C4F6420D26CCF4EA2683A47', 1, 'enUS');"

echo "Changing realmd name"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $REALM_DB_NAME -e "UPDATE realmlist set name='$REALM_NAME', address='$REALM_ADRESS', port='$REALM_PORT', icon='$REALM_ICON', realmflags='$REALM_FLAG', timezone='$REALM_TIMEZONE', allowedSecurityLevel='$REALM_SECURITY', population='$REALM_POP', realmbuilds='$REALM_BUILD' WHERE id = '1';"

echo "Importing world data"
cp -v /etc/InstallFullDB.sh /opt/tbc-db
cp -v /etc/InstallFullDB.config /opt/tbc-db

echo "Updating InstallFullDB.config"
sed -i -e '/MYSQL_HOST=/ s/=.*/="'${MYSQL_HOST}'"/' /opt/tbc-db/InstallFullDB.config
sed -i -e '/MYSQL_PORT=/ s/=.*/="'${MYSQL_PORT}'"/' /opt/tbc-db/InstallFullDB.config
sed -i -e '/MYSQL_USERNAME=/ s/=.*/="'${MYSQL_USERNAME}'"/' /opt/tbc-db/InstallFullDB.config
sed -i -e '/MYSQL_PASSWORD=/ s/=.*/="'${MYSQL_PASSWORD}'"/' /opt/tbc-db/InstallFullDB.config
sed -i -e '/MYSQL_USERIP=/ s/=.*/="'${MYSQL_USERIP}'"/' /opt/tbc-db/InstallFullDB.config
sed -i -e '/WORLD_DB_NAME=/ s/=.*/="'${WORLD_DB_NAME}'"/' /opt/tbc-db/InstallFullDB.config
sed -i -e '/REALM_DB_NAME=/ s/=.*/="'${REALM_DB_NAME}'"/' /opt/tbc-db/InstallFullDB.config
sed -i -e '/CHAR_DB_NAME=/ s/=.*/="'${CHAR_DB_NAME}'"/' /opt/tbc-db/InstallFullDB.config
sed -i -e '/LOGS_DB_NAME=/ s/=.*/="'${LOGS_DB_NAME}'"/' /opt/tbc-db/InstallFullDB.config

sed -i -e '/CORE_PATH=/ s/=.*/="'${CORE_PATH}'"/' /opt/tbc-db/InstallFullDB.config
sed -i -e '/LOCALES=/ s/=.*/="'${LOCALES}'"/' /opt/tbc-db/InstallFullDB.config
sed -i -e '/FORCE_WAIT=/ s/=.*/="'${FORCE_WAIT}'"/' /opt/tbc-db/InstallFullDB.config
sed -i -e '/DEV_UPDATES=/ s/=.*/="'${DEV_UPDATES}'"/' /opt/tbc-db/InstallFullDB.config
sed -i -e '/AHBOT=/ s/=.*/="'${AHBOT}'"/' /opt/tbc-db/InstallFullDB.config

cd /opt/tbc-db
./InstallFullDB.sh -World
