ARG BASE_IMAGE=debian:bookworm-slim
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

# Set timezone if $TZ is provided
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install compilers, build tools, and dev libraries (Bookworm versions)
RUN apt-get update && apt-get install -y \
    tzdata vim tmux git \
    clang clang-tools lldb \
    libreadline-dev cmake libssl-dev make gcc g++ \
    libboost-all-dev libace-dev libbz2-dev unzip wget \
    default-mysql-client default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy dispatcher script (utility entrypoint)
COPY utility /bin/utility
RUN chmod +x /bin/utility

# Copy all command scripts (e.g., compile.sh, init_db.sh, etc.)
COPY commands/ /bin/commands/
RUN chmod +x /bin/commands/*.sh

# Set dispatcher as entrypoint
ENTRYPOINT ["/bin/utility"]