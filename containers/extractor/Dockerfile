FROM debian:bullseye-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y tzdata libssl1.1 libboost-all-dev libace-dev libreadline-dev

WORKDIR /opt/wow
RUN cp /opt/server/bin/m* /opt/wow && cp /opt/server/vmap* /opt/wow
RUN sysctl -w kernel.core_pattern=/tmp/core-%e.%p.%h.%t

ENTRYPOINT [ "/bin/bash" ]

# This is a vay to generate core dump files.
# See https://stackoverflow.com/a/69832851

# ENTRYPOINT [ "./mmaps_generator" ]
