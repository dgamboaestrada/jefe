FROM php:7.0-fpm

RUN apt-get update && \
    apt-get install -y libfreetype6-dev libjpeg62-turbo-dev curl git && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/  &&  \
    docker-php-ext-install gd && \
    docker-php-ext-install zip && \
    docker-php-ext-install pdo_mysql

# Install composer
RUN apt-get update
RUN apt-get install --yes curl git
RUN curl -sS https://getcomposer.org/installer | php
RUN chmod +x composer.phar
RUN mv composer.phar /usr/local/bin/composer
