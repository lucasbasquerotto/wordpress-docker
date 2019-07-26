FROM composer:1.8.6 AS builder

COPY . /tmp/main

RUN cd /tmp/main \
 && composer install

FROM php:7.3.7-apache

RUN docker-php-ext-install mysqli \
 && docker-php-ext-enable mysqli

ENV WPCLI_VERSION 2.2.0

RUN apt-get update \
 && apt-get install -y \
    less \
    zlib1g-dev \
    libzip-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && docker-php-ext-install zip

# mysql-client
 
# Install wp-cli
RUN curl -OL \
    https://github.com/wp-cli/wp-cli/releases/download/v${WPCLI_VERSION}/wp-cli-${WPCLI_VERSION}.phar \
 && chmod +x wp-cli-${WPCLI_VERSION}.phar \
 && mv wp-cli-${WPCLI_VERSION}.phar /usr/local/bin/wp

# Enable tab completion and prepare www-data home directory
RUN curl -o /tmp/wp-completion.bash \
    https://raw.githubusercontent.com/wp-cli/wp-cli/v${WPCLI_VERSION}/utils/wp-completion.bash \
 && echo 'source /tmp/wp-completion.bash' >> /root/.bashrc \
 && echo "alias wp='wp --allow-root'" >> /root/.bashrc

COPY --from=builder --chown=www-data:www-data /tmp/main /var/www/html/
COPY --chown=www-data:www-data apache/wp.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html
