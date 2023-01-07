#!/bin/sh

escape() {
  local tmp=`echo $1 | sed 's/[^a-zA-Z0-9\s:]/\\\&/g'`
  echo "$tmp"
}

if [ ! -d "/opt/etc/pandaria_5.4.8" ]; then
   cd /opt/etc
   git clone https://github.com/alexkulya/pandaria_5.4.8
   mkdir -p /opt/etc/pandaria_5.4.8/build
else
   cd /opt/etc/pandaria_5.4.8
   git pull
fi

if [ ! -d "/opt/server/logs" ]; then
   mkdir -p /opt/server/logs
fi

if [ ! -d "/opt/server/honor" ]; then
   mkdir -p /opt/server/honor
fi

if [ ! -d "/opt/server/etc" ]; then
   mkdir -p /opt/server/etc
fi


cd /opt/etc/pandaria_5.4.8/build

cmake .. -DCMAKE_INSTALL_PREFIX=/opt/server -DCMAKE_C_COMPILER=/usr/bin/clang-11 -DCMAKE_CXX_COMPILER=/usr/bin/clang++-11 -DSCRIPTS=static -DWITH_WARNINGS=0 -DTOOLS=0

make clean
make -j $(nproc) install

# authserver.conf
sed -i -e "/LogsDir =/ s/= .*/= $(escape $LOGS_DIR_PATH)/" $CONFIG_PATH/authserver.conf
sed -i -e "/LoginDatabaseInfo =/ s/= .*/= \"$(escape $DB_CONTAINER)\;3306\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;realmd\"/" $CONFIG_PATH/authserver.conf

# worldserver.conf
sed -i -e "/DataDir =/ s/= .*/= $(escape $DATA_DIR_PATH)/" $CONFIG_PATH/worldserver.conf
sed -i -e "/Warden.ModuleDir             =/ s/= .*/= $(escape $WARDEN_DIR_PATH)/" $CONFIG_PATH/worldserver.conf

sed -i -e "/LoginDatabase.Info              =/ s/= .*/= \"$(escape $DB_CONTAINER)\;3306\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;realmd\"/" $CONFIG_PATH/worldserver.conf
sed -i -e "/WorldDatabase.Info              =/ s/= .*/= \"$(escape $DB_CONTAINER)\;3306\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;worldserver\"/" $CONFIG_PATH/worldserver.conf
sed -i -e "/CharacterDatabase.Info          =/ s/= .*/= \"$(escape $DB_CONTAINER)\;3306\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;characters\"/" $CONFIG_PATH/worldserver.conf
sed -i -e "/LogsDatabase.Info               =/ s/= .*/= \"$(escape $DB_CONTAINER)\;3306\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;logs\"/" $CONFIG_PATH/worldserver.conf

sed -i -e "/GameType =/ s/= .*/= $(escape $GAME_TYPE)/" $CONFIG_PATH/worldserver.conf
sed -i -e "/RealmZone =/ s/= .*/= $(escape $REALM_ZONE)/" $CONFIG_PATH/worldserver.conf
sed -i -e "/Motd =/ s/= .*/= $(escape $MOTD_MSG)/" $CONFIG_PATH/worldserver.conf

sed -i -e "/Ra.Enable =/ s/= .*/= $(escape $RA_ENABLE)/" $CONFIG_PATH/worldserver.conf
sed -i -e "/AHBot.Enable  =/ s/= .*/= $(escape $AH_ENABLE)/" $CONFIG_PATH/worldserver.conf
sed -i -e "/AHBot.itemcount =/ s/= .*/= $(escape $AH_ITEM_COUNT)/" $CONFIG_PATH/worldserver.conf

sed -i -e "/SOAP.Enabled =/ s/= .*/= $(escape $SOAP_ENABLE)/" $CONFIG_PATH/worldserver.conf
sed -i -e "/SOAP.IP =/ s/= .*/= $(escape $SOAP_IP)/" $CONFIG_PATH/worldserver.conf

