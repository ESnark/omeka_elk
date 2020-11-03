FROM php:7.4.4-apache

RUN a2enmod rewrite

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get -qq -y --no-install-recommends install \
    curl \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libjpeg-dev \
    libmemcached-dev \
    libonig-dev \
    zlib1g-dev \
    imagemagick

RUN docker-php-ext-install -j$(nproc) iconv \
    pdo pdo_mysql mysqli gd mbstring
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/

RUN docker-php-ext-install exif && \
    docker-php-ext-enable exif

COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml


VOLUME /var/www/html

CMD ["apache2-foreground"]
