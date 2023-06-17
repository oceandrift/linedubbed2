FROM docker.io/debian:bookworm-slim
RUN apt-get update && apt-get -y install \
    php-cli \
    php-curl \
    tar \
    xzutils
COPY ./tools /opt/ldri
