#
# Dockerfile for MACCMS
#

# syntax=docker/dockerfile:1

FROM php:7.4-apache

RUN set -ex \
    && apt-get update && apt-get install -y \
       git \
       unzip \
       libfreetype-dev \
       libjpeg-dev \
       libwebp-dev \
       libzip-dev \
    && docker-php-ext-install -j$(nproc) mysqli pdo_mysql sockets zip \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && pecl install redis-5.3.7 \
    && docker-php-ext-enable redis \
    && docker-php-ext-install -j$(nproc) gd \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /tmp/* /var/lib/apt/lists/*

RUN set -ex \
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && a2enmod remoteip \
    && sed -i 's/%h/%a/g' /etc/apache2/apache2.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

COPY <<EOT /etc/apache2/mods-enabled/remoteip.conf
RemoteIPHeader X-Forwarded-For
RemoteIPTrustedProxy 127.0.0.0/8
RemoteIPTrustedProxy ::1/128
EOT

COPY . /var/www/html

RUN chown -R www-data:www-data /var/www/html
RUN chown -R www-data:www-data /var/www/html/application
RUN chown -R www-data:www-data /var/www/html/runtime
RUN chown -R www-data:www-data /var/www/html/upload
RUN chown -R www-data:www-data /var/www/html/static
RUN chown -R www-data:www-data /var/www/html/addons

EXPOSE 80