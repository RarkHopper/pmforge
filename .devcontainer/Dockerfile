ARG PMMP_VERSION=5.27.0
ARG PHP_BUILD_VERSION=pm5-php-8.3


FROM ubuntu:20.04 AS pmmp

ARG PMMP_VERSION

RUN apt-get update -y && apt-get install -y \
        curl \
        wget  && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# PMMPのインストール
RUN mkdir /pmmp && \
    curl -fSsL "https://github.com/pmmp/PocketMine-MP/releases/download/${PMMP_VERSION}/PocketMine-MP.phar" -o "/pmmp/PocketMine-MP.phar" && \
    curl -fSsL "https://github.com/pmmp/PocketMine-MP/releases/download/${PMMP_VERSION}/start.sh" -o "/pmmp/start.sh" && \
    chmod +x /pmmp/start.sh


FROM ubuntu:20.04 AS pmmp-php

ARG PHP_BUILD_VERSION
ARG ARCH=x86_64
ARG OS=Linux

RUN apt-get update -y && apt-get install -y \
        wget  && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# PMMP PHPバイナリをダウンロードして展開
RUN mkdir /opt/pmmp-php && \
    wget -O /tmp/php.tar.gz https://github.com/pmmp/PHP-Binaries/releases/download/${PHP_BUILD_VERSION}-latest/PHP-${PHP_BUILD_VERSION#*-php-}-${OS}-${ARCH}-PM5.tar.gz && \
    tar -xzf /tmp/php.tar.gz -C /opt/pmmp-php && \
    rm /tmp/php.tar.gz

# opcache.so のフルパスに書き換える
RUN OPCACHE_SO=$(find /opt/pmmp-php -name opcache.so 2>/dev/null || true) && \
    if [ -f "$OPCACHE_SO" ]; then \
        sed -i "s|^zend_extension=opcache.so|zend_extension=${OPCACHE_SO}|" /opt/pmmp-php/bin/php7/bin/php.ini; \
    fi

# xdebug.so のフルパスに書き換える
RUN XDEBUG_SO=$(find /opt/pmmp-php -name xdebug.so) && \
    if [ -f "$XDEBUG_SO" ]; then \
        sed -i "s|^;zend_extension=xdebug.so|zend_extension=${XDEBUG_SO}|" /opt/pmmp-php/bin/php7/bin/php.ini; \
    fi


FROM mcr.microsoft.com/devcontainers/base:ubuntu-20.04

# 必要なパッケージのインストール
RUN apt-get update -y && apt-get install -y \
        python3 \
        python3-pip \
        git \
        unzip \
        curl \
        zip \
        vim \
        jq \
        libxml2-dev \
        libzip-dev && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# PMMPのインストール
COPY --from=pmmp /pmmp/ /pmmp/
COPY --from=pmmp-php /opt/pmmp-php/ /opt/pmmp-php/

RUN chown -R vscode:vscode /pmmp

# Composerインストール
COPY --from=composer:2.8.4 /usr/bin/composer /usr/bin/composer

RUN pip install pre-commit

# PHPバイナリのパスを通す
ENV PATH="/opt/pmmp-php/bin/php7/bin/:${PATH}"
