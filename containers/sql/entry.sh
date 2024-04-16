#!/bin/sh

#    echo "Starting Initialization of CMaNGOS DB..."
#    echo "Check database sql files"

#    git config --global --add safe.directory $SOURCE_PREFIX
#    git config --global pull.rebase false

#    if [ ! -d "$SOURCE_PREFIX" ]; then
#       git clone https://github.com/alexkulya/pandaria_5.4.8 $SOURCE_PREFIX
#    else
#       cd $SOURCE_PREFIX
#       git pull
#    fi

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

    unzip $SOURCE_PREFIX/sql/base/auth_04_03_2023.zip -d /tmp
    unzip $SOURCE_PREFIX/sql/base/characters_04_03_2023.zip -d /tmp
    unzip $SOURCE_PREFIX/sql/base/world_04_03_2023.zip -d /tmp

    
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth < /tmp/auth_04_03_2023.sql
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD characters < /tmp/characters_04_03_2023.sql
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/world_04_03_2023.sql

    # download latest world database
    if [ ! -f "$ROOT_DIRECTORY/build/2023_12_10_world.zip" ]; then
        wget --progress=bar:force:noscroll https://github.com/alexkulya/pandaria_5.4.8/releases/download/%23pandaria548world/2023_12_10_world.zip -O $ROOT_DIRECTORY/build/2023_12_10_world.zip
    fi


    unzip $ROOT_DIRECTORY/build/2023_12_10_world.zip -d /tmp
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/2023_12_10_world.sql

    # pv $ROOT_DIRECTORY/build/2023_12_10_world.zip | bsdtar -xf - -C /tmp

    cat $SOURCE_PREFIX/sql/updates/auth/*.sql > /tmp/auth.sql
    cat $SOURCE_PREFIX/sql/updates/characters/*.sql > /tmp/characters.sql
    cat $SOURCE_PREFIX/sql/updates/world/*.sql > /tmp/world.sql
    cat $SOURCE_PREFIX/sql/updates/world/battlepay/*.sql >> /tmp/world.sql
    cat $SOURCE_PREFIX/sql/updates/world/localization/enUS/*.sql >> /tmp/world.sql
    cat $SOURCE_PREFIX/sql/updates/world/localization/ruRU/*.sql >> /tmp/world.sql

    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth < /tmp/auth.sql
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD characters < /tmp/characters.sql
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/world.sql

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

    touch /etc/configured
