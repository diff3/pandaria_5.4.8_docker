FROM mariadb:latest

RUN apt-get update && apt-get -y install git unzip 
COPY --chmod=755 entry.sh /docker-entrypoint-initdb.d
