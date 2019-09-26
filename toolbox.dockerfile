FROM ubuntu:18.04

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    awscli \
    curl \
    iproute2 \
    iputils-ping \
    lsof \
    manpages \
    man-db \
    nano \
    s3cmd \
    tasksel \
    telnet \
    time \
    unzip \
    wget \
    zip \
 && rm -rf /var/lib/apt/lists/*