#!/bin/sh

echo "Starting Initialization of CMaNGOS DB..."



# if [ ! -d "$SOURCE_PREFIX" ]; then
#   cd /opt/build
#   git clone $GIT_URL_SOURCE $SOURCE_PREFIX
#else
#   cd $SOURCE_PREFIX
##   git config --global --add safe.directory /opt/build/pandaria_5.4.8
#   git checkout master --force
#   git pull
# fi

if [ "$USEBRANCH" -eq 1 ]; then
   echo "Using branch"

   cd $SOURCE_PREFIX
   git config --global --add safe.directory /opt/build/pandaria_5.4.8

   if ! git show-ref --verify --quiet "refs/heads/$BRANCH"; then
      echo "Creating branch"
      git checkout -b $BRANCH $GIT_TAG
   else
      echo "Switching branch"
      git checkout $BRANCH
   fi
else
   echo "using main"
fi

upload_sql_files() {
    local directory="$1"
    local database="$2"

    # Check if the directory exists
    if [ ! -d "$directory" ]; then
        echo "Directory $directory does not exist"
        return 1
    fi

    # Check if the database name is valid
    # You may want to add more comprehensive validation here
    if [ -z "$database" ]; then
        echo "Database name is required"
        return 1
    fi

    # Iterate over all SQL files in the directory
    for sql_file in "$directory"/*.sql; do
        if [ -f "$sql_file" ]; then
            # Upload the SQL file to the specified database
            mariadb -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" "$database" < "$sql_file"
	    echo "$sql_file added to $database"
        fi
    done

    echo "All SQL files in $directory have been uploaded to database $database"
}

    echo "Removing old database and users"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS auth;"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS characters"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS world"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP USER IF EXISTS pandaria"

    echo "Creating databases"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE auth;"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE characters"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE world"

    echo "Create user"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE USER '$SERVER_DB_USER'@'%' IDENTIFIED BY '$SERVER_DB_PASSWORD';"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON auth.* to '$SERVER_DB_USER'@'%';"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON characters.* to '$SERVER_DB_USER'@'%';"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON world.* to '$SERVER_DB_USER'@'%';"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "FLUSH PRIVILEGES;"

    echo "Unzipping base database files"
    unzip $SOURCE_PREFIX/sql/base/auth_04_03_2023.zip -d /tmp
    unzip $SOURCE_PREFIX/sql/base/characters_04_03_2023.zip -d /tmp
    unzip $SOURCE_PREFIX/sql/base/world_04_03_2023.zip -d /tmp

    echo "Populate database"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth < /tmp/auth_04_03_2023.sql
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD characters < /tmp/characters_04_03_2023.sql
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/world_04_03_2023.sql

    # download latest world database
    if [ ! -f "$ROOT_DIRECTORY/build/2023_12_10_world.zip" ]; then
	echo "Dodnloading latest world db"
        wget --progress=bar:force:noscroll https://github.com/alexkulya/pandaria_5.4.8/releases/download/%23pandaria548world/2023_12_10_world.zip -O $ROOT_DIRECTORY/build/2023_12_10_world.zip
    fi
    
    echo "Unzipping latest db"
    unzip $ROOT_DIRECTORY/build/2023_12_10_world.zip -d /tmp

    echo "Populate database with latest world db"
    mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/2023_12_10_world.sql

    # pv $ROOT_DIRECTORY/build/2023_12_10_world.zip | bsdtar -xf - -C /tmp

    # echo "" > /tmp/world.sql
    echo "Update databases to latest"

   upload_sql_files "$SOURCE_PREFIX/sql/updates/auth" "auth"
   upload_sql_files "$SOURCE_PREFIX/sql/updates/characters" "characters"
   upload_sql_files "$SOURCE_PREFIX/sql/updates/world" "world"
   upload_sql_files "$SOURCE_PREFIX/sql/updates/world/battlepay" "world"
   upload_sql_files "$SOURCE_PREFIX/sql/updates/world/localization/enUS" "world"
   upload_sql_files "$SOURCE_PREFIX/sql/updates/world/localization/ruRU" "world"

    # cat -A $SOURCE_PREFIX/sql/updates/auth/*.sql > /tmp/auth.sql
    # cat -A $SOURCE_PREFIX/sql/updates/characters/*.sql > /tmp/characters.sql
    # cat -A $SOURCE_PREFIX/sql/updates/world/*.sql > /tmp/world.sql
    # cat -A $SOURCE_PREFIX/sql/updates/world/battlepay/*.sql >> /tmp/world.sql
    # cat -A $SOURCE_PREFIX/sql/updates/world/localization/enUS/*.sql >> /tmp/world.sql
    # cat -A $SOURCE_PREFIX/sql/updates/world/localization/ruRU/*.sql >> /tmp/world.sql

    echo "populate updates"
    # mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth < /tmp/auth.sql
    # mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD characters < /tmp/characters.sql
    # mariadb -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/world.sql

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
