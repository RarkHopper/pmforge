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
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# PMMP PHPバイナリをダウンロードして展開
RUN mkdir -p ${PMMP_PHP_DIR} && \
    wget -O /tmp/php.tar.gz https://github.com/pmmp/PHP-Binaries/releases/download/${P}-${V}/PHP-${P#*-php-}-${OS}-${ARCH}-PM5.tar.gz && \
    tar -xzf /tmp/php.tar.gz -C ${PMMP_PHP_DIR} && \
    rm /tmp/php.tar.gz

# Composerインストール
COPY --from=composer:2.8.4 /usr/bin/composer /usr/bin/composer

# Install additional tools and libraries that might be needed by phpstan and php-cs-fixer
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libzip-dev \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN pip install pre-commit

ENV PATH="${PMMP_PHP_BIN}/bin:${PATH}"
