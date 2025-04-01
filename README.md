# PMForge - PocketMine-MPプラグイン開発テンプレート

PMForgeは、PocketMine-MP (PMMP) プラグイン開発のための効率的な開発環境テンプレートです。Docker devcontainerを使用して一貫した開発環境を提供し、プラグイン開発のワークフローを簡素化します。

## 特徴

- Docker devcontainerによる完全に構成済みの開発環境
- 迅速なプラグイン初期化スクリプト
- PHPStan、PHP-CS-Fixerによるコード品質管理ツール
- シンプルなPHARビルドシステム
- 自動PMMPサーバーセットアップ機能
- 便利なMakeコマンド群

## 開発環境のセットアップ

### 必要条件

- Docker
- VS Code + Dev Containers拡張機能

### セットアップ手順

1. リポジトリをクローンします
2. `.env.example`を`.env`にコピーして必要に応じて設定を編集します
3. VS Codeで開き、「Reopen in Container」を選択します
4. devcontainerが自動的に開発環境をセットアップします

## PMMPサーバーのセットアップ

`.env`ファイルを使用して、PMMPサーバーの設定をカスタマイズできます：

```bash
# PMMPサーバーをセットアップ
make pmmp-setup

# 既存のPMMPサーバーを完全に削除
make pmmp-purge
```

### .env ファイルの設定

`.env.example`をコピーして`.env`を作成します。これは、PMMPサーバーのセットアップに必要な環境変数を設定するための重要なファイルです。

```bash
# .env.exampleから.envを作成
cp .env.example .env
```

`.env`で設定可能な項目：
- `PMMP_VERSION` - PocketMine-MPのバージョン (例: 5.27.0)
  - [PocketMine-MP Releases](https://github.com/pmmp/PocketMine-MP/releases)から利用可能なバージョンを確認できます
- `PHP_BUILD_VERSION` - PHPビルドのバージョン (例: pm5-php-8.3)
  - [PHP-Binaries Releases](https://github.com/pmmp/PHP-Binaries/releases)から利用可能なバージョンを確認できます
- `ARCH` - アーキテクチャ (x86_64, arm64, x64など)
  - 通常のLinux/Macでは`x86_64`、Windowsでは`x64`を使用します
- `OS` - 対象OS (Linux, Windows, MacOS)
  - プラグインをテストするホストOSを指定します
- `BASE_PATH` - PMMPサーバーのインストール先パス
  - Windowsでの使用例: `/mnt/c/pmmp`（WSLからアクセス可能なWindowsのパス）
  - Linux/Macでの使用例: `/home/user/pmmp`

これらの設定は、`make pmmp-setup`実行時にPMMPサーバーとPHPバイナリを適切にダウンロードおよび設定するために使用されます。

## 使用方法

### 新しいプラグインの作成

```bash
make init-plugin
```

対話形式でプラグイン名、バージョン、作者情報などを入力し、基本的なプラグインプロジェクト構造を生成します。composer.jsonの設定も自動的に更新されます。

### コード品質管理

```bash
# PHPStanでの静的解析
make analyse

# PHP-CS-Fixerでのコードスタイル修正
make fix

# コードスタイルチェック（修正なし）
make check
```

### ビルドと実行

```bash
# プラグインのPHARをビルド
make build

# PMMPサーバーを起動
make run

# ビルドしたプラグインをPMMPサーバーに配置
make deploy

# ビルドとデプロイを一度に実行
make redeploy
```

### プロジェクトのクリーンアップ

```bash
make clean
```

## ディレクトリ構造

- `/.devcontainer` - Docker開発環境の設定
- `/scripts` - 各種ユーティリティスクリプト
  - `build-phar.php` - PHARファイル生成スクリプト
  - `build-phar.sh` - PHAR生成のシェルラッパー
  - `init-plugin.sh` - 新規プラグイン初期化スクリプト
  - `setup-pmmp.sh` - PMMPサーバーセットアップスクリプト
- `/src` - プラグインのソースコード
- `/builds` - ビルドされたPHARファイル

## その他の情報

- `.editorconfig` - エディタ共通設定
- `.pre-commit-config.yaml` - git pre-commitフック設定
- `.php-cs-fixer.dist.php` - コードスタイル設定
- `phpstan.neon` - 静的解析設定
- `.env` - 環境変数設定 (.env.exampleからコピーして作成)
