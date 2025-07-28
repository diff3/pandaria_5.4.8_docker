# Select base image (default: Debian 12 / bookworm)
ARG BASE_IMAGE=debian:bookworm-slim
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime libraries only
RUN apt-get update && apt-get install -y \
    libace-dev \          
    libssl3 \            
    libmariadb3 \       
    libreadline8 \   
    libncurses6 \    
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default working directory
WORKDIR /app

# Default command (can be overridden by ENV)
ENV START_AUTH="./bin/authserver"

ENTRYPOINT ["/entrypoint.sh"]