FROM docker.io/debian:bookworm-slim
RUN apt-get update && apt-get -y install \
    dub \
    git \
    ldc
RUN git clone --depth=1 --branch=v2.4.0 https://github.com/dlang/dub-registry.git /opt/dub-registry
WORKDIR /opt/dub-registry
RUN dub build --build=release --config=application
CMD /opt/dub-registry/dub-registry --bind 0.0.0.0 --p 80
