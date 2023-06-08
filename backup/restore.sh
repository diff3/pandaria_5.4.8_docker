#!/bin/sh

docker exec -i pandaria-mariadb mysql -u root -ppwd < pandaria.sql
