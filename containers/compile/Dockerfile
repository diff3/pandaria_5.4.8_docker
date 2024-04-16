FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y tzdata vim tmux git clang libreadline-dev cmake libssl-dev make gcc g++ \ 
libboost-all-dev libace-dev wget lsb-release gnupg libbz2-dev 
# libmariadb-dev-compat libmariadb-dev
# B7B3B788A8D3785C 467B942D3A79BD29

RUN echo 'deb http://repo.mysql.com/apt/ubuntu bionic mysql-5.7' > /etc/apt/sources.list.d/mysql.list && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7B3B788A8D3785C && \ 
mv /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d && \
apt-get update && apt-get install -y mysql-client=5.7* mysql-community-server=5.7* mysql-server=5.7* libmysqlclient20 libmysqlclient-dev

COPY entry.sh /
RUN chmod +x /entry.sh

ENTRYPOINT ["/entry.sh"]
# ENTRYPOINT ["/bin/bash"]
