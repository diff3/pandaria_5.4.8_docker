#!/bin/sh 

docker exec pandariadb mariadb-dump -u root -ppwd --databases auth > auth.sql
docker exec pandariadb mariadb-dump -u root -ppwd --databases characters > characters.sql
docker exec pandariadb mariadb-dump -u root -ppwd --databases world > world.sql

cat auth.sql characters.sql world.sql > pandaria.sql

# docker exec pandariadb mariadb-dump -u root -ppwd --databases auth characters world > pandaria.sql
