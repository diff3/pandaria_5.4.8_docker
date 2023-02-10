FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y tzdata libssl1.1 libboost-all-dev libace-dev gnupg2 libreadline-dev wget

WORKDIR /opt/wow
RUN cp /opt/server/bin/m* /opt/wow && cp /opt/server/vmap* /opt/wow

ENTRYPOINT [ "/bin/bash" ]
