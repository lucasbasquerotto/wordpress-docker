FROM ubuntu:18.04

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    curl \
    iproute2 \
    iputils-ping \
    lsof \
    manpages \
    man-db \
    nano \
    tasksel \
    telnet \
    time \
    wget \
    zip \
 && rm -rf /var/lib/apt/lists/*