# Pandaria 5.4.8 docker



This docker container will include all dependencies and program to compile and run **[pandaria 5.4.8](https://github.com/alexkulya/pandaria_5.4.8)** in a docker container. With seperated containers for compile, mariadb, authserver and worldserver. It also has a phpmyadmin container for easy database editing.



It does compile and create database automatecly, it also make a basic configure of worldserver.conf and authserver.conf then your are compiling server. Just enough to log in on your own computer. 



You can use 'telnet localhost 3443' with admin:admin to create more accounts. 



dbc, maps, mmaps and vmaps can be downloaded from **[pandaria 5.4.8](https://github.com/alexkulya/pandaria_5.4.8)** and are needed to be placed in server/data directory.



The containers will not work on Mac silicon M1 because MySQL 5 does not got any install cantidate on Debian arm. 



## Install  



### Linux

Tested on Debian 11, Arch and Majarno linux
Dependencies: docker and git



**Quickie!**

Place dbc, maps, mmaps and vmaps in 'server/data' dir
ctrl-c to exit log view

```bash
# Go and make dinner, it will take a while
docker compose up --build compile && docker compose down && docker compose up -d && docker compose logs -f
```



**Extended**


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

