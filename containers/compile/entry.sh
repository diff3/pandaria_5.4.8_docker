#!/bin/sh

escape() {
  local tmp=`echo $1 | sed 's/[^a-zA-Z0-9\s:]/\\\&/g'`
  echo "$tmp"
}

if [ ! -d "$SOURCE_PREFIX" ]; then
   cd /opt/etc
   git clone $GIT_URL_SOURCE $SOURCE_PREFIX
else
   cd $SOURCE_PREFIX
   git pull
fi

if [ ! -d "$INSTALL_PREFIX/logs" ]; then
   mkdir -p $INSTALL_PREFIX/logs
fi

if [ ! -d "$INSTALL_PREFIX/etc" ]; then
   mkdir -p $INSTALL_PREFIX/etc
fi

if [ ! -d "$SOURCE_PREFIX/build" ]; then
   mkdir -p $SOURCE_PREFIX/build
fi

cd $SOURCE_PREFIX/build

cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DCMAKE_C_COMPILER=$CMAKE_C_COMPILER -DCMAKE_CXX_COMPILER=$CMAKE_CXX_COMPILER -DSCRIPTS=$SCRIPTS -DWITH_WARNINGS=$WARNINGS -DTOOLS=$EXTRACTORS -DCMAKE_CXX_FLAGS=$CMAKE_CXX_FLAGS

make clean

if [ $MAKE_INSTALL -eq 1 ];then
   echo "Make install"
   make -j $(nproc) install
fi

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

if [ $MAKE_INSTALL -eq 0 ]; then
   echo "Open shell"
   /bin/bash
fi
