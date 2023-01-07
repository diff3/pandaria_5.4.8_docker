#!/bin/sh

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
