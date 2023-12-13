#!/bin/sh 

docker exec pandaria-mariadb mariadb-dump -u root -ppwd --databases auth > auth.sql
docker exec pandaria-mariadb mariadb-dump -u root -ppwd --databases characters > characters.sql
docker exec pandaria-mariadb mariadb-dump -u root -ppwd --databases world > world.sql

cat auth.sql characters.sql world.sql > pandaria.sql

# docker exec pandaria-mariadb mariadb-dump -u root -ppwd --databases auth characters world > pandaria.sql
