FROM php:7.4-cli

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.

## Dependencial linux
RUN apt-get update && apt-get install -y --no-install-recommends \
  autoconf \
  build-essential \
  git-flow \
  apt-utils \
  zlib1g-dev \
  libzip-dev \
  unzip \
  zip \
  libmagick++-dev \
  libmagickwand-dev \
  libpq-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libwebp-dev \ 
  libxpm-dev \
  wget \
  zsh && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ARG USERNAME=developer
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

## Install extensions
RUN pecl install redis && \
    pecl install xdebug && \
    docker-php-ext-install gd pdo_mysql zip exif pcntl xml  && \
    docker-php-ext-enable redis xdebug && \
    echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo 'xdebug.remote_port=9000' >> /usr/local/etc/php/php.ini && \    
    echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini
    
## Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require laravel/installer

RUN curl -LO https://deployer.org/deployer.phar && \
    mv deployer.phar /usr/local/bin/dep && \
    chmod +x /usr/local/bin/dep 

USER $USERNAME
ENV PATH="$PATH:/var/www/vendor/bin"
# set the zsh
ENV ZSH_THEME=agnoster
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
