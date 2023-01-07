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

if [ ! -f "/opt/server/etc/authserver.conf" ]; then
   echo "updating authserver.conf files"
   cp /opt/server/etc/authserver.conf.dist /opt/server/etc/authserver.conf

   sed -i -e "/LogsDir =/ s/= .*/= $(escape $LOGS_DIR_PATH)/" $CONFIG_PATH/authserver.conf
   sed -i -e "/LoginDatabaseInfo =/ s/= .*/= \"$(escape $DB_CONTAINER)\;3306\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;auth\"/" $CONFIG_PATH/authserver.conf
fi

if [ ! -f "/opt/server/etc/worldserver.conf" ]; then
   echo "updating worldserver.conf files"
   cp /opt/server/etc/worldserver.conf.dist /opt/server/etc/worldserver.conf

   sed -i -e "/DataDir =/ s/= .*/= $(escape $DATA_DIR_PATH)/" $CONFIG_PATH/worldserver.conf
   sed -i -e "/LogsDir =/ s/= .*/= $(escape $LOGS_DIR_PATH)/" $CONFIG_PATH/worldserver.conf

   sed -i -e "/LoginDatabaseInfo     =/ s/= .*/= \"$(escape $DB_CONTAINER)\;3306\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;auth\"/" $CONFIG_PATH/worldserver.conf
   sed -i -e "/WorldDatabaseInfo     =/ s/= .*/= \"$(escape $DB_CONTAINER)\;3306\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;world\"/" $CONFIG_PATH/worldserver.conf
   sed -i -e "/CharacterDatabaseInfo =/ s/= .*/= \"$(escape $DB_CONTAINER)\;3306\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;characters\"/" $CONFIG_PATH/worldserver.conf
   sed -i -e "/ArchiveDatabaseInfo   =/ s/= .*/= \"$(escape $DB_CONTAINER)\;3306\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;archive\"/" $CONFIG_PATH/worldserver.conf
   sed -i -e "/FusionCMSDatabaseInfo =/ s/= .*/= \"$(escape $DB_CONTAINER)\;3306\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;fusion\"/" $CONFIG_PATH/worldserver.conf

   sed -i -e "/GameType =/ s/= .*/= $(escape $GAME_TYPE)/" $CONFIG_PATH/worldserver.conf
   sed -i -e "/RealmZone =/ s/= .*/= $(escape $REALM_ZONE)/" $CONFIG_PATH/worldserver.conf
   sed -i -e "/Motd =/ s/= .*/= \"$(escape $MOTD_MSG)\"/" $CONFIG_PATH/worldserver.conf

   sed -i -e "/Ra.Enable =/ s/= .*/= $(escape $RA_ENABLE)/" $CONFIG_PATH/worldserver.conf

   sed -i -e "/SOAP.Enabled =/ s/= .*/= $(escape $SOAP_ENABLE)/" $CONFIG_PATH/worldserver.conf
   sed -i -e "/SOAP.IP =/ s/= .*/= $(escape $SOAP_IP)/" $CONFIG_PATH/worldserver.conf
fi

