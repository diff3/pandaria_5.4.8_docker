FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install only runtime libraries (ACE, OpenSSL, MySQL client lib)
RUN apt-get update && apt-get install -y \
    libace-7.* libace-dev \
    libssl3  default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Run the authserver binary from /app/bin
CMD ["./bin/authserver"]