# Pandaria 5.4.8 docker



This docker container will include all dependencies to compile and run [**pandaria 5.4.8**](https://github.com/alexkulya/pandaria_5.4.8) in a docker container. With separate containers for compile, MariaDB, Authserver, and Worldserver. It also has a PHPMyAdmin container for easy database editing.

It does compile and creates the databases automatically. It also makes a basic configuration of worldserver.conf and authserver.conf when you  compiled the server. Just enough to log in on your computer.

You can use 'telnet localhost 3443' with admin:admin to create more accounts.

Before you start the server, you need to place dbc, maps, vmaps, and mmaps in the server/data directory. They can all be downloaded from [**pandaria 5.4.8**](https://github.com/alexkulya/pandaria_5.4.8)

You can also compile pandaria with tools, and use extractor container to create dbc, maps, vmaps, and mmaps from your MoP client. At the moment it's manual work only! <advanced user only>

The containers will not work on Mac silicon M1 because MySQL 5 does not have any install candidate on Debian arm.

I don't use Windows, so I can't test if it work, probebly not without some modifications.

Before starting MariaDB check mariadb.env file in the env folder. If you want access from some other computer then local you need to add your computer IP number instead of 127.0.0.1


If you need to get coredump working see info from stackoverflow, extractor container got some information as well.
https://stackoverflow.com/a/69832851


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
