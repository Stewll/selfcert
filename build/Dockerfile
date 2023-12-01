FROM debian:latest

RUN apt-get update && apt-get install -y openssl
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
COPY crt.conf /app/crt.conf
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]