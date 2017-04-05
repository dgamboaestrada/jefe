FROM php:7.0-fpm

RUN docker-php-ext-install pdo_mysql

# Install composer
RUN apt-get install curl
RUN curl -sS https://getcomposer.org/installer | php
RUN chmod +x composer.phar
RUN mv composer.phar /usr/local/bin/composer
