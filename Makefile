# Include environment variables from .env file
ifneq (,$(wildcard ./.env))
include .env
export
endif

# 必須変数のチェック
ifndef PMMP_VERSION
$(error PMMP_VERSION が設定されていません。.env ファイルを確認してください)
endif
ifndef PHP_BUILD_VERSION
$(error PHP_BUILD_VERSION が設定されていません。.env ファイルを確認してください)
endif
ifndef ARCH
$(error ARCH が設定されていません。.env ファイルを確認してください)
endif
ifndef OS
$(error OS が設定されていません。.env ファイルを確認してください)
endif
ifndef BASE_PATH
$(error BASE_PATH が設定されていません。.env ファイルを確認してください)
endif

.PHONY: help init-plugin clean analyse fix check build run pmmp-setup pmmp-purge deploy redeploy

help:
	@echo "使用可能なコマンド:"
	@echo "  make help                - このヘルプメッセージを表示"
	@echo "  make init-plugin         - 新しいプラグインを初期化"
	@echo "  make clean               - ソースファイルとプラグイン設定を削除"
	@echo "  make analyse             - PHPStanでコード解析を実行"
	@echo "  make fix                 - PHP-CS-Fixerでコードスタイルを修正"
	@echo "  make check               - コードスタイルをチェック（変更なし）"
	@echo "  make build               - プラグインをPHARファイルにビルド"
	@echo "  make pmmp-setup          - PMMPサーバー環境をセットアップ"
	@echo "  make pmmp-purge          - PMMPディレクトリを完全に削除"
	@echo "  make run                 - PMMPサーバーを起動"
	@echo "  make deploy              - ビルドしたプラグインをPMMPディレクトリにデプロイ"
	@echo "  make redeploy            - ビルドとデプロイを一度に実行"

init-plugin:
	- @make clean
	- chmod +x ./scripts/init-plugin.sh
	- bash ./scripts/init-plugin.sh

clean:
	- rm -rf ./src/*
	- rm plugin.yml

analyse:
	- ./vendor/bin/phpstan analyse

fix:
	- ./vendor/bin/php-cs-fixer fix

check:
	- ./vendor/bin/php-cs-fixer fix --dry-run --diff

build:
	- chmod +x ./scripts/build-phar.sh
	- ./scripts/build-phar.sh

pmmp-setup:
	- @echo "セットアップを開始します："
	- @echo "PMMP_VERSION = $(PMMP_VERSION)"
	- @echo "PHP_BUILD_VERSION = $(PHP_BUILD_VERSION)"
	- @echo "ARCH = $(ARCH)"
	- @echo "OS = $(OS)"
	- @echo "BASE_PATH = $(BASE_PATH)"
	- chmod +x ./scripts/setup-pmmp.sh
	- ./scripts/setup-pmmp.sh "$(PMMP_VERSION)" "$(PHP_BUILD_VERSION)" "$(ARCH)" "$(OS)" "$(BASE_PATH)"

# PMMPディレクトリを完全に削除するコマンド
pmmp-purge:
	@echo "PMMPディレクトリを完全に削除します..."
	@echo "$(BASE_PATH)を削除中..."
	@rm -rf "$(BASE_PATH)" || true
	@echo "PMMPディレクトリの削除が完了しました。再セットアップするには 'make pmmp-setup' を実行してください。"

run:
	- @-fuser -k 19132/udp || true
	- @if [ "$(OS)" = "Windows" ]; then \
		echo "WindowsのPMMPサーバーは手動で起動してください。"; \
	else \
		rm -f "$(BASE_PATH)/server.lock" || true; \
		cd "$(BASE_PATH)" && bash "start.sh"; \
	fi

# ビルドしたプラグインをPMMPディレクトリにデプロイする
deploy:
	@echo "ビルドしたプラグインをデプロイします..."
	@if [ ! -d "builds" ]; then \
		echo "ビルドディレクトリが見つかりません。先に 'make build' を実行してください。"; \
		exit 1; \
	fi
	@echo "$(BASE_PATH)環境にデプロイ中..."; \
	mkdir -p "$(BASE_PATH)/plugins"; \
	cp -v builds/* "$(BASE_PATH)/plugins/" || true;
	@echo "プラグインのデプロイが完了しました。"

# プラグインのビルドとデプロイを一度に行う
redeploy: build deploy
	@echo "ビルドとデプロイが完了しました。"
