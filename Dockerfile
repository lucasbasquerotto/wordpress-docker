FROM composer:1.8.6 AS builder

COPY . /tmp/main

RUN cd /tmp/main \
 && composer install

FROM php:7.3.7-apache

# docker-php-ext-install pdo_mysql

RUN docker-php-ext-install mysqli \
 && docker-php-ext-enable mysqli

COPY --from=builder --chown=www-data:www-data /tmp/main /var/www/html/
COPY --chown=www-data:www-data apache/wp.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html
