FROM composer:1.8.6 AS builder

COPY . /tmp/main

RUN cd /tmp/main \
 && composer install

FROM php:7.3.7-fpm

RUN apt-get update \
 && apt-get install -y nginx \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/main /var/www/html/

WORKDIR /var/www/html

# forward request and error logs to docker log collector
RUN ln -sf /dev/null /var/log/nginx/access.log \
 && ln -sf /dev/null /var/log/nginx/error.log \
 && mv /var/www/html/nginx.conf /etc/nginx/nginx.conf

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]