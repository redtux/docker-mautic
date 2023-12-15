# syntax=docker/dockerfile:1.2
#
# SPDX-FileCopyrightText: 2015-2016 Michael Babker <michael.babker@mautic.org>
# SPDX-FileCopyrightText: 2017-2018 Petr Gregor <gregy@gregy.cz>
# SPDX-FileCopyrightText: 2017-2020 Luiz Eduardo de Oliveira Fonseca <luizeof@gmail.com>
# SPDX-FileCopyrightText: 2018 Alan Pazetto <alancpazetto@gmail.com>
# SPDX-FileCopyrightText: 2018 Joachim C. <contact@ston3o.me> (@johackim)
# SPDX-FileCopyrightText: 2019 Mathieu Brunot <mathieu.brunot@monogramm.io>
# SPDX-FileCopyrightText: 2019 Regev Brody <regevbr@gmail.com>
# SPDX-FileCopyrightText: 2023 Pablo Hörtner <redtux@pm.me>
# SPDX-License-Identifier: GPL-3.0-or-later
#
# You can find the GPL 3.0 here:  https://www.gnu.org/licenses/gpl-3.0
# The Mautic releases live here:  https://github.com/mautic/mautic/releases

# Define PHP version and SHA256 hash
ARG PHP_VERSION="${PHP_VERSION:-7.4.33}"
ARG PHP_SHA256="${PHP_SHA256:-924846abf93bc613815c55dd3f5809377813ac62a9ec4eb3778675b82a27b927}"
FROM "php:${PHP_VERSION}-apache"

# Define Mautic version and SHA1 hash
ENV MAUTIC_VERSION 4.4.10
ENV MAUTIC_SHA1 8da80700b742d67dc7d952196adf0506b2ba0535

# Set metadata labels
LABEL maintainer="Pablo Hörtner <redtux@pm.me> (@redtux)" \
      org.opencontainers.image.description="Mautic ${MAUTIC_VERSION} · PHP ${PHP_VERSION} · Apache" \
      org.opencontainers.image.source="https://github.com/redtux/mautic" \
      vendor="redgnus"

# Define environment variables
ENV MAUTIC_RELEASE_URL=https://github.com/mautic/mautic/releases/download \
    MAUTIC_RUN_CRON_JOBS=true \
    MAUTIC_RUN_MIGRATIONS=false \
    MAUTIC_DB_USER=root \
    MAUTIC_DB_NAME=mautic \
    MAUTIC_DB_PORT=3306 \
    PHP_INI_DATE_TIMEZONE='UTC' \
    PHP_MEMORY_LIMIT=512M \
    PHP_MAX_UPLOAD=512M \
    PHP_MAX_EXECUTION_TIME=300

# Install system dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    ca-certificates \
    cron \
    curl \
    imagemagick \
    graphicsmagick \
    libaprutil1-dev \
    libc-client-dev \
    libcurl4-gnutls-dev \
    libfreetype6-dev \
    libgif-dev \
    libicu-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    libkrb5-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libonig-dev \
    libpng-dev \
    libssl-dev \
    libtiff-dev \
    libwebp-dev \
    libxpm-dev \
    libxml2-dev \
    libzip-dev \
    sudo \
    unzip \
    wget \
    zip \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/* \
  && rm /etc/cron.daily/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install \
        bcmath \
        curl \
        exif \
        gd \
        imap \
        intl \
        mbstring \
        mysqli \
        opcache \
        pdo_mysql \
        sockets \
        zip \
    && docker-php-ext-enable \
        bcmath \
        curl \
        exif \
        gd \
        imap \
        intl \
        mbstring \
        mysqli \
        opcache \
        pdo_mysql \
        sockets \
        zip

# Copy necessary files
COPY docker-entrypoint.sh /entrypoint.sh
COPY makeconfig.php /makeconfig.php
COPY makedb.php /makedb.php
COPY mautic.crontab /etc/cron.d/mautic

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Define Mautic volume to persist data
VOLUME /var/www/html

# Download Mautic package and extract to web volume
RUN curl -o mautic.zip -SL "${MAUTIC_RELEASE_URL}/${MAUTIC_VERSION}/${MAUTIC_VERSION}.zip" \
    && echo "$MAUTIC_SHA1 *mautic.zip" | sha1sum -c - \
    && mkdir /usr/src/mautic \
    && unzip mautic.zip -d /usr/src/mautic \
    && rm mautic.zip \
    && chown -R www-data:www-data /usr/src/mautic

# Set file permissions
RUN chmod 644 /etc/cron.d/mautic \
 && chmod 755 /entrypoint.sh

# Enable the Apache rewrite module
RUN a2enmod rewrite

# Define entrypoint and command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
