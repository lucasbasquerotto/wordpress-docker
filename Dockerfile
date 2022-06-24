FROM lucasbasquerotto/wordpress:composer-2.3.7-php-8.1.7 AS builder

COPY . /var/www/html

RUN cd /var/www/html \
 && composer install

FROM php:8.1.7-apache

RUN docker-php-ext-install mysqli \
 && docker-php-ext-enable mysqli

ENV WPCLI_VERSION 2.5.0

RUN apt-get update \
 && apt-get install -y \
    curl \
    less \
    libmemcached-dev \
    libzip-dev \
    nano \
    unzip \
    zip \
    zlib1g-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && pecl channel-update pecl.php.net \
 && yes '' | pecl install redis memcached apcu \
 && docker-php-ext-install zip \
 && docker-php-ext-enable redis memcached apcu \
 && a2enmod rewrite

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

COPY --from=builder --chown=www-data:www-data /var/www/html/ /var/www/html/

COPY --chown=www-data:www-data apache/wp.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html
