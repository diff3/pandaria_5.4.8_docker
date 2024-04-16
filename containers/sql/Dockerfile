FROM mariadb:latest

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get -y install unzip libarchive-tools pv
# COPY entry.sh /docker-entrypoint-initdb.d
COPY entry.sh /
