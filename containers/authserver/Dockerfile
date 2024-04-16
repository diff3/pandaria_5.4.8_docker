FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y tzdata libssl1.1 libboost-all-dev libace-dev gnupg2 libreadline-dev 
# libmariadb-dev-compat libmariadb-dev

RUN echo 'deb http://repo.mysql.com/apt/ubuntu bionic mysql-5.7' > /etc/apt/sources.list.d/mysql.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7B3B788A8D3785C
RUN apt-get update && apt-get install -y libmysqlclient20 libmysqlclient-dev

WORKDIR /opt/server/bin
# ENTRYPOINT [ "/bin/bash" ]
ENTRYPOINT [ "./authserver" ]
