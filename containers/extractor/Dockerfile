FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV MAPS=ON VMAPS=ON MMAPS=ON 

RUN apt-get update && apt-get install -y tzdata libssl1.1 libboost-all-dev libace-dev libreadline-dev

COPY entry.sh /
RUN chmod +x /entry.sh

ENTRYPOINT [ "/entry.sh" ]
