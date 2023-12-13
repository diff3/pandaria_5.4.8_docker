#!/bin/sh

echo "Starting Initialization of CMaNGOS DB..."

echo "Check database sql files"

if [ ! -d "/opt/build/pandaria_5.4.8" ]; then
	git clone https://github.com/alexkulya/pandaria_5.4.8 /opt/build/pandaria_5.4.8
else
	cd /opt/build/pandaria_5.4.8
	git config --global --add safe.directory /opt/build/pandaria_5.4.8
	git pull
	cd /
fi

echo "Removing old database and users"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS auth;"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS characters"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS world"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP USER IF EXISTS pandaria"

echo "Creating databases"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE auth;"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE characters"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE world"

echo "Creat user"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE USER 'pandaria'@'%' IDENTIFIED BY 'pandaria';"

mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON auth.* to 'pandaria'@'%';"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON characters.* to 'pandaria'@'%';"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON world.* to 'pandaria'@'%';"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "FLUSH PRIVILEGES;"

echo "Populate database"
unzip /opt/build/pandaria_5.4.8/sql/base/auth_04_03_2023.zip -d /tmp
unzip /opt/build/pandaria_5.4.8/sql/base/characters_04_03_2023.zip -d /tmp
unzip /opt/build/pandaria_5.4.8/sql/base/world_04_03_2023.zip -d /tmp

mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth < /tmp/auth_04_03_2023.sql
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD characters < /tmp/characters_04_03_2023.sql
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/world_04_03_2023.sql

# download world db if needed.
if [ ! -f "/opt/build/2023_12_10_world.zip" ]; then 
	wget https://github.com/alexkulya/pandaria_5.4.8/releases/download/%23pandaria548world/2023_12_10_world.zip -O /tmp/2023_12_10_world.zip
fi

cd /tmp
unzip 2023_12_10_world.zip
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/2023_12_10_world.sql

cat /opt/build/pandaria_5.4.8/sql/updates/auth/*.sql > /tmp/auth.sql
cat /opt/build/pandaria_5.4.8/sql/updates/characters/*.sql > /tmp/characters.sql
cat /opt/build/pandaria_5.4.8/sql/updates/world/*.sql > /tmp/world.sql
cat /opt/build/pandaria_5.4.8/sql/updates/world/battlepay/*.sql >> /tmp/world.sql
cat /opt/build/pandaria_5.4.8/sql/updates/world/localization/enUS/*.sql >> /tmp/world.sql

mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth < /tmp/auth.sql
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD characters < /tmp/characters.sql
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/world.sql

mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth < /opt/build/pandaria_5.4.8/sql/old/auth/auth.currency_transactions.sql

echo "User cleanup"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "DELETE FROM account"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "DELETE FROM account_access"

echo "Adding admin user"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "INSERT INTO account (id, username, sha_pass_hash) VALUES (1, 'admin', '8301316d0d8448a34fa6d0c6bf1cbfa2b4a1a93a');"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "INSERT INTO account_access (id, gmlevel , RealmID) VALUES (1, 100, -1)";

echo "Update realmd info"
mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "DELETE FROM realmlist;"

mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "INSERT INTO realmlist (id, name, project_shortname, address, port, icon, color, timezone, allowedSecurityLevel, population, gamebuild, flag, project_hidden, project_enabled, project_dbname, project_dbworld, project_dbarchive, project_rates_min, project_rates_max, project_transfer_level_max, project_transfer_items, project_transfer_skills_spells, project_transfer_glyphs, project_transfer_achievements, project_server_same, project_server_settings, project_server_remote_path, project_accounts_detach, project_setskills_value_max, project_chat_enabled, project_statistics_enabled) VALUES (1, '$REALM_NAME', '$REALM_NAME', '$REALM_ADDRESS', '$REALM_PORT', $REALM_ICON, $REALM_COLOR, $REALM_TIMEZONE, $REALM_SECURITY, $REALM_POP, $REALM_BUILD, $REALM_FLAG, 0, 1, '', '', '', 0, 0, 80, 'IGNORE', 'IGNORE', 'IGNORE', 'IGNORE', 0, '0', '0', 1, 0, 0, 0);"

echo "Removing files"
yes | rm -r /tmp/*.sql
