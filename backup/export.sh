#!/bin/sh 

# docker exec pandaria-mariadb mysqldump -u root -ppwd --databases archive auth characters fusion world > pandaria.sql
docker exec pandaria-mariadb mysqldump -u root -ppwd --databases archive auth characters world > pandaria.sql
