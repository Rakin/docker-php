FROM php:7.2-apache

ARG USERNAME=www
ARG USER_UID=1000
ARG USER_GID=$USER_UID

## Env var
ENV APACHE_RUN_USER $USERNAME
ENV APACHE_RUN_GROUP $USERNAME    
ENV PATH "/root/.composer/vendor/bin:~/.composer/vendor/bin:/var/www/vendor/bin:$PATH"
ENV COMPOSER_MEMORY_LIMIT -1

## Dependencial linux
RUN apt-get update && apt-get install -y \
    sudo \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    unzip \
    git-flow \
    curl \
    nodejs \
    npm \
    cron \
    libxml2-dev \
    libz-dev \ 
    libmemcached-dev \
    libxrender1 \
    libfontconfig1 \
    libx11-dev \
    libxtst6 \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## Create the user
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME


## Set working directory 
WORKDIR /var/www

#### Install all dependencies wkhtmltopdf
RUN wget https://github.com/h4cc/wkhtmltopdf-amd64/blob/master/bin/wkhtmltopdf-amd64?raw=true -O /usr/local/bin/wkhtmltopdf && \
    chmod +x /usr/local/bin/wkhtmltopdf

## Install extensions
RUN pecl install memcached redis && \
    docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ && \
    docker-php-ext-install gd pdo_mysql mbstring zip exif pcntl xml  && \
    docker-php-ext-enable redis memcached

## Install xdebug
RUN yes | pecl install xdebug && \
    echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    echo 'xdebug.remote_port=9001' >> /usr/local/etc/php/php.ini && \
    echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini

## Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer global require hirak/prestissimo

## Grunt
RUN npm install -g grunt-cli

## mod_rewrite
RUN a2enmod rewrite

USER $USERNAME
