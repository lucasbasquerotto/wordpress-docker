FROM lucasbasquerotto/wordpress:composer-1.8.6 AS builder

COPY . /tmp/main

RUN cd /tmp/main \
 && rm -rf web/app/plugins \
 && mkdir web/app/plugins \
 && rm -rf web/app/themes \
 && mkdir web/app/themes \
 && composer install

FROM php:7.3.8-apache

RUN docker-php-ext-install mysqli \
 && docker-php-ext-enable mysqli

ENV WPCLI_VERSION 2.2.0

RUN apt-get update \
 && apt-get install -y \
    curl \
    less \
    libzip-dev \
    nano \
    unzip \
    zip \
    zlib1g-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && docker-php-ext-install zip \
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

COPY --from=builder --chown=www-data:www-data /tmp/main /var/www/html/

# W3 Total Cache
ENV W3TC_VERSION 0.14.4

RUN mkdir -p /var/www/html/web/app/plugins \
 && curl -L https://downloads.wordpress.org/plugin/w3-total-cache.${W3TC_VERSION}.zip \
    -o /tmp/w3-total-cache.zip \
 && unzip /tmp/w3-total-cache.zip -d /var/www/html/web/app/plugins \
 && rm /tmp/w3-total-cache.zip \
 && chown -R www-data:www-data /var/www/html/web/app/plugins \
 && cp /var/www/html/web/app/plugins/w3-total-cache/wp-content/advanced-cache.php \
    /var/www/html/web/app/advanced-cache.php \
 && chown www-data:www-data /var/www/html/web/app/advanced-cache.php \
 && mkdir -p /var/www/html/web/app/cache \
 && chown www-data:www-data /var/www/html/web/app/cache \
 && mkdir -p /var/www/html/web/app/w3tc-config \
 && chown www-data:www-data /var/www/html/web/app/w3tc-config

COPY --chown=www-data:www-data apache/wp.conf /etc/apache2/sites-available/000-default.conf

# COPY --chown=www-data:www-data /wordpress/containers/wordpress/plugins/w3tc/app/w3tc-config/ /var/www/html/web/app/w3tc-config/
# COPY --chown=www-data:www-data /wordpress/containers/wordpress/plugins/w3tc/app/advanced-cache.php /var/www/html/web/app/
# COPY --chown=www-data:www-data /wordpress/containers/wordpress/plugins/w3tc/app/object-cache.php /var/www/html/web/app/
# COPY --chown=www-data:www-data /wordpress/containers/wordpress/plugins/w3tc/.htaccess /var/www/html/web/

WORKDIR /var/www/html
