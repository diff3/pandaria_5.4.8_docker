# Pandaria 5.4.8 docker



This docker container will include all dependencies and program to compile and run **[pandaria 5.4.8](https://github.com/alexkulya/pandaria_5.4.8)** in a docker container. Usually you only run one program per container, but you can run the whole server with tmux. I will write an update with seperated container for world, auth and databases. 



It does not compile everything automatecly, so you have to log into the container to start the compile.



dbc, maps, mmaps and vmaps can be downloaded from **[pandaria 5.4.8](https://github.com/alexkulya/pandaria_5.4.8)**



## Install  



### Linux

```bash
https://github.com/diff3/pandaria_5.4.8_docker
cd pandaria_5.4.8_docker
cd etc
git clone https://github.com/alexkulya/pandaria_5.4.8
cd ..

docker compose up -d
docker exec -it pandaria-compile /bin/bash

# inside docker container

mkdir -p /opt/etc/pandaria_5.4.8/build
cd /opt/etc/pandaria_5.4.8/build

cmake .. -DCMAKE_INSTALL_PREFIX=/opt/server -DCMAKE_C_COMPILER=/usr/bin/clang-11 -DCMAKE_CXX_COMPILER=/usr/bin/clang++-11 -DSCRIPTS=static -DWITH_WARNINGS=0

# this will take a long while.
make install

# all files kan be found at /opt/server
```

