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
    unzip \
    wget \
    zip \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    s3cmd \
 && rm -rf /var/lib/apt/lists/*