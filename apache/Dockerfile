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

ARG PHP_VERSION="${PHP_VERSION:-7.1.33}"
FROM "php:${PHP_VERSION}-apache"

LABEL vendor="redgnus"
LABEL maintainer="Pablo Hörtner <redtux@pm.me> (@redtux)"
LABEL org.opencontainers.image.source="https://github.com/redtux/mautic"

# Install PHP extensions
RUN apt-get update && apt-get install --no-install-recommends -y \
    cron \
    git \
    wget \
    sudo \
    libc-client-dev \
    libicu-dev \
    libkrb5-dev \
    libmcrypt-dev \
    libssl-dev \
    libz-dev \
    unzip \
    zip \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/cron.daily/*

RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install imap intl mbstring mcrypt mysqli pdo_mysql zip opcache bcmath\
    && docker-php-ext-enable imap intl mbstring mcrypt mysqli pdo_mysql zip opcache bcmath

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Define Mautic volume to persist data
VOLUME /var/www/html

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 4.4.10
ENV MAUTIC_SHA1 8da80700b742d67dc7d952196adf0506b2ba0535

# By default enable cron jobs
ENV MAUTIC_RUN_CRON_JOBS true

# Setting an root user for test
ENV MAUTIC_DB_USER root
ENV MAUTIC_DB_NAME mautic

# Setting PHP properties
ENV PHP_INI_DATE_TIMEZONE='UTC' \
    PHP_MEMORY_LIMIT=512M \
    PHP_MAX_UPLOAD=128M \
    PHP_MAX_EXECUTION_TIME=300

# Download package and extract to web volume
RUN curl -o mautic.zip -SL https://github.com/mautic/mautic/releases/download/${MAUTIC_VERSION}/${MAUTIC_VERSION}.zip \
    && echo "$MAUTIC_SHA1 *mautic.zip" | sha1sum -c - \
    && mkdir /usr/src/mautic \
    && unzip mautic.zip -d /usr/src/mautic \
    && rm mautic.zip \
    && chown -R www-data:www-data /usr/src/mautic

# Copy init scripts and custom .htaccess
COPY docker-entrypoint.sh /entrypoint.sh
COPY makeconfig.php /makeconfig.php
COPY makedb.php /makedb.php
COPY mautic.crontab /etc/cron.d/mautic
RUN chmod 644 /etc/cron.d/mautic

# Enable Apache Rewrite Module
RUN a2enmod rewrite

# Apply necessary permissions
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
