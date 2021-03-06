FROM php:7.2-apache

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.

## Dependencial linux
RUN apt-get update && apt-get install -y \
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

#### Install all dependencies wkhtmltopdf
RUN wget https://github.com/h4cc/wkhtmltopdf-amd64/blob/master/bin/wkhtmltopdf-amd64?raw=true -O /usr/local/bin/wkhtmltopdf && \
    chmod +x /usr/local/bin/wkhtmltopdf

## Install extensions
RUN pecl install memcached redis xdebug && \
    docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ && \
    docker-php-ext-install gd pdo_mysql mbstring zip exif pcntl xml  && \
    docker-php-ext-enable redis memcached && \
    echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo 'xdebug.remote_port=9001' >> /usr/local/etc/php/php.ini && \
    echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini

## Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf  && \
    a2enmod rewrite

# Uses "git", "ssh-agent" and "history-substring-search" bundled plugins
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -- \
    -p git -p ssh-agent -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'

ARG USERNAME=www
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

ENV APACHE_RUN_USER www
ENV APACHE_RUN_GROUP www