FROM docker.io/debian:bookworm-slim
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y install \
    php-cli \
    php-curl \
    tar \
    xz-utils
COPY ./tools /opt/ldri
