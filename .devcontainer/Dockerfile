FROM mcr.microsoft.com/devcontainers/dev-php:8.3

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

# Composerインストール
COPY --from=composer:2.8.4 /usr/bin/composer /usr/bin/composer

RUN pip install pre-commit
