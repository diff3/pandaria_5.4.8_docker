FROM mariadb:latest

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get -y install unzip libarchive-tools git wget
RUN groupadd -g 1000 readvolume
RUN usermod -a -G readvolume mysql
RUN mkdir -p /opt/build 
VOLUME /opt/build

COPY entry.sh /docker-entrypoint-initdb.d
