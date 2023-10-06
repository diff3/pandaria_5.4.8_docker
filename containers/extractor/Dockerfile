FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV MAPS=ON VMAPS=ON MMAPS=ON 

RUN apt-get update && apt-get install -y tzdata libssl1.1 libboost-all-dev libace-dev libreadline-dev

WORKDIR /
COPY --chmod=755 entry.sh /

# ENTRYPOINT [ "/bin/bash" ]
ENTRYPOINT [ "./entry.sh" ]
