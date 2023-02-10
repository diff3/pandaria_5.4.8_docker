FROM debian:bullseye-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y tzdata libssl1.1 libboost-all-dev libace-dev gnupg2 libreadline-dev wget

RUN echo 'deb http://repo.mysql.com/apt/ubuntu bionic mysql-5.7' > /etc/apt/sources.list.d/mysql.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29

RUN apt-get update && apt-get install -y libmysqlclient20 libmysqlclient-dev

WORKDIR /opt/server/bin
ENTRYPOINT [ "./authserver" ]
