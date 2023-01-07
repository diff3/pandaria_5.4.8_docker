# Pandaria 5.4.8 docker



This docker container will include all dependencies and program to compile and run **[pandaria 5.4.8](https://github.com/alexkulya/pandaria_5.4.8)** in a docker container. With seperated containers for compile, mariadb, authserver and worldserver. It also has a phpmyadmin container for easy database editing.



It does compile and create database automatecly, but at the monent you need to update the config files otherwise it wont connect to database.



dbc, maps, mmaps and vmaps can be downloaded from **[pandaria 5.4.8](https://github.com/alexkulya/pandaria_5.4.8)**



The containers will not work on Mac silicon M1 because MySQL 5 does not got any install cantidate on Debian arm. 



## Install  



### Linux

Tested on Debian 11, Arch and Majarno linux
Dependencies: docker and git



```bash
git clone https://github.com/diff3/pandaria_5.4.8_docker
cd pandaria_5.4.8_docker

# compile
docker compose up -d compile && docker compose down

# start authserver, mariadb and worldserver
docker compose up -d

# start phpmyadmin
docker compose up -d phpmyadmin

# stop servers
docker compose stop

# start server
docker compose start

# remove servers
docker compose down
```

