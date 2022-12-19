FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y tzdata libssl1.1 libboost-all-dev libace-dev gnupg2 libreadline-dev wget

RUN echo 'deb http://repo.mysql.com/apt/ubuntu bionic mysql-5.7' > /etc/apt/sources.list.d/mysql.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29

RUN apt-get update && apt-get install -y libmysqlclient20 
RUN wget https://repo.mysql.com/apt/ubuntu/pool/mysql-5.7/m/mysql-community/libmysqlclient-dev_5.7.40-1ubuntu18.04_amd64.deb -P /tmp
RUN dpkg -i /tmp/libmysqlclient-dev_5.7.40-1ubuntu18.04_amd64.deb

WORKDIR /opt/server/bin
CMD ./worldserver
