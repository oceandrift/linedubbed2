FROM docker.io/debian:bookworm-slim

# install popular/common libraries to be able to run test suites of certain packages
RUN apt-get update && apt-get -y install \
    libsqlite3-dev
