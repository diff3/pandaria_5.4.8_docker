#!/bin/sh 

docker exec pandaria-mariadb mysqldump -u root -ppwd --databases auth characters world > pandaria.sql
