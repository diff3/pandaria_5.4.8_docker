#!/bin/sh

echo "Starting Initialization of CMaNGOS DB..."

echo "Check database sql files"

if [ ! -d "/opt/etc/pandaria_5.4.8" ]; then
	git clone https://github.com/alexkulya/pandaria_5.4.8 /opt/etc/pandaria_5.4.8
else
	cd /opt/etc/pandaria_5.4.8
	git pull
	cd /
fi

echo "Removing old database and users"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS archive;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS auth;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS characters"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS fusion"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS world"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP USER IF EXISTS pandara"

echo "Creating databases"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE archive;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE auth;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE characters"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE fusion"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE world"

echo "Creat user"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE USER 'pandara'@'%' IDENTIFIED BY 'pandara';"

mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON archive.* to 'pandara'@'%';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON auth.* to 'pandara'@'%';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON characters.* to 'pandara'@'%';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON fusion.* to 'pandara'@'%';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON world.* to 'pandara'@'%';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "FLUSH PRIVILEGES;"

echo "Populate database"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD archive < /opt/etc/pandaria_5.4.8/sql/base/archive.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth < /opt/etc/pandaria_5.4.8/sql/base/auth.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD characters < /opt/etc/pandaria_5.4.8/sql/base/characters.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD fusion < /opt/etc/pandaria_5.4.8/sql/base/fusion.sql

7z e /opt/etc/pandaria_5.4.8/sql/base/world.7z -o/tmp
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/world.sql

cat /opt/etc/pandaria_5.4.8/sql/updates/auth\/old/*.sql > /tmp/auth.sql
cat /opt/etc/pandaria_5.4.8/sql/updates/characters/*.sql > /tmp/characters.sql
cat /opt/etc/pandaria_5.4.8/sql/updates/world/*.sql > /tmp/world.sql

mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth < /tmp/auth.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD characters < /tmp/characters.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/world.sql

echo "User cleanup"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "DELETE FROM account"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "DELETE FROM account_access"

echo "Adding admin user"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "INSERT INTO account (id, username, sha_pass_hash) VALUES (1, 'admin', '8301316d0d8448a34fa6d0c6bf1cbfa2b4a1a93a');"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "INSERT INTO account_access (id, gmlevel , RealmID) VALUES (1, 100, -1)";

echo "Update realmd info"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "DELETE FROM realmlist WHERE id='2';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "UPDATE realmlist SET NAME='$REALM_NAME',project_shortname='$REALM_NAME', address='$REALM_ADRESS', port='$REALM_PORT', icon='$REALM_ICON', flag='$REALM_FLAG', timezone='$REALM_TIMEZONE', allowedSecurityLevel='$REALM_SECURITY', population='$REALM_POP', gamebuild='$REALM_BUILD' WHERE id = '1';"

echo "Removing files"
yes | rm -r /tmp/*.sql
