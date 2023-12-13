FROM mariadb:latest

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get -y install git unzip wget

COPY entry.sh /docker-entrypoint-initdb.d
RUN chmod +x /docker-entrypoint-initdb.d/entry.sh
