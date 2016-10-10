FROM php:7.0.11-fpm
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    automake \
    libtool \
    libmemcached-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libpq-dev \
    libpng12-dev \
    libjpeg62-turbo-dev \
    mysql-client \
    pkg-config \
    libxml2-dev \
    libxml2 \
    git \
    libicu-dev \
    libmagickwand-dev \
    unzip \
    curl \
    libcurl4-gnutls-dev \
    libexif-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd opcache iconv mcrypt pdo_pgsql pdo_mysql mbstring mysqli soap intl zip curl exif bcmath \
    && pecl install imagick \
    && docker-php-ext-enable imagick \ 
    && rm -r /var/lib/apt/lists/* \
    && rm -r /var/cache/apt/*

RUN git clone git://github.com/alanxz/rabbitmq-c.git \
    && cd rabbitmq-c \
    && git submodule init \
    && git submodule update \
    && autoreconf -i \
    && ./configure --prefix=/usr/local/ \
    && make -j$(nproc) \
    && make install


RUN pecl install redis amqp \
    && docker-php-ext-enable redis amqp

RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p memcached \
    && tar -C memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && ( \
        cd memcached \
        && phpize \
        && ./configure \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r memcached \
    && rm /tmp/memcached.tar.gz \
    && docker-php-ext-enable memcached

RUN apt-get autoremove 

COPY ./php.ini /usr/local/etc/php/conf.d/php.ini
COPY ./php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/bin --filename=composer

CMD ["php-fpm", "-F"]
