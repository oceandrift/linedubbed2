FROM docker.io/debian:bookworm-slim
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y install socat
ENTRYPOINT ["/usr/bin/socat", "TCP-LISTEN:443,fork,reuseaddr", "TCP:code.dlang.org:443"]
