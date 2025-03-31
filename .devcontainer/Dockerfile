FROM mcr.microsoft.com/devcontainers/base:ubuntu-20.04

ARG P=pm5-php-8.3
ARG V=latest
ARG ARCH=x86_64
ARG OS=Linux

# PHPバイナリの展開先
ENV PMMP_PHP_DIR=/opt/pmmp-php
ENV PMMP_PHP_BIN=${PMMP_PHP_DIR}/bin/php7

# 必要なパッケージ
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    unzip \
    curl \
    zip \
    vim \
    jq \
    libxml2-dev \
    libzip-dev \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# PMMP PHPバイナリをダウンロードして展開
RUN mkdir -p ${PMMP_PHP_DIR} && \
    wget -O /tmp/php.tar.gz https://github.com/pmmp/PHP-Binaries/releases/download/${P}-${V}/PHP-${P#*-php-}-${OS}-${ARCH}-PM5.tar.gz && \
    tar -xzf /tmp/php.tar.gz -C ${PMMP_PHP_DIR} && \
    rm /tmp/php.tar.gz

# opcache.so のフルパスに書き換える
RUN OPCACHE_SO=$(find ${PMMP_PHP_DIR} -name opcache.so 2>/dev/null || true) && \
    if [ -f "$OPCACHE_SO" ]; then \
        sed -i "s|^zend_extension=opcache.so|zend_extension=${OPCACHE_SO}|" ${PMMP_PHP_BIN}/bin/php.ini; \
    fi

# xdebug.so のフルパスに書き換える
RUN XDEBUG_SO=$(find ${PMMP_PHP_DIR} -name xdebug.so) && \
    if [ -f "$XDEBUG_SO" ]; then \
        sed -i "s|^;zend_extension=xdebug.so|zend_extension=${XDEBUG_SO}|" ${PMMP_PHP_BIN}/bin/php.ini; \
    fi

# Composerインストール
COPY --from=composer:2.8.4 /usr/bin/composer /usr/bin/composer

RUN pip install pre-commit

ENV PATH="${PMMP_PHP_BIN}/bin:${PATH}"
