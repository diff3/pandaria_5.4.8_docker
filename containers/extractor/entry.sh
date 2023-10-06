#!/bin/sh

cd /opt/server/bin

mkdir -p /opt/server/data

if [ $MAPS = 'ON' ]; then
   echo "Extracting: camera, dbc and maps"
   ./mapextractor -i '/opt/wow' -o /opt/server/data
fi

if [ $VMAPS = 'ON' ];  then
  echo "Extracting: vmaps"
  mkdir /opt/server/data/vmaps
  cd /opt/wow && cp /opt/server/bin/vmap4extractor .
  ./vmap4extractor -l -b /opt/server/data

  cd /opt/server/bin
  echo "Assambling: vmaps"
  ./vmap4assembler /opt/wow/Buildings /opt/server/data/vmaps
fi

if [ $MMAPS = 'ON' ];  then
  echo "EXTRACTING: mmaps"
  mkdir /opt/server/data/mmaps
  cd /opt/server/data && cp /opt/server/bin/mmaps_generator .
  ./mmaps_generator
fi

rm -r /opt/wow/Buildings
rm /opt/wow/vmap4extractor
rm /opt/server/data/mmaps_generator
