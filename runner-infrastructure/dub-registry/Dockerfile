FROM docker.io/debian:bookworm-slim
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y install socat
CMD /usr/bin/socat TCP4-LISTEN:8080,fork,reuseaddr TCP4:code.dlang.org:443
