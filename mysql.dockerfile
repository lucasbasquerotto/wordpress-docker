FROM mysql:8.0.16

RUN apt-get update \
 && apt-get install -y --no-install-recommends pv \
 && rm -rf /var/lib/apt/lists/*

CMD ["mysqld", "--default-authentication-plugin=mysql_native_password"]