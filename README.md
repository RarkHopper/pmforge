# PMForge - PocketMine-MPプラグイン開発テンプレート

PMForgeは、PocketMine-MP (PMMP) プラグイン開発のための効率的な開発環境テンプレートです。Docker devcontainerを使用して一貫した開発環境を提供し、プラグイン開発のワークフローを簡素化します。

## 特徴

- Docker devcontainerによる完全に構成済みの開発環境
- 迅速なプラグイン初期化スクリプト
- PHPStan、PHP-CS-Fixerによるコード品質管理ツール
- シンプルなPHARビルドシステム
- 便利なMakeコマンド群

## 開発環境のセットアップ

### 必要条件

- Docker
- VS Code + Dev Containers拡張機能

### セットアップ手順

1. リポジトリをクローンします
2. VS Codeで開き、「Reopen in Container」を選択します
3. devcontainerが自動的に開発環境をセットアップします

## 使用方法

### 新しいプラグインの作成

```bash
make init-plugin
```

対話形式でプラグイン名、バージョン、作者情報などを入力し、基本的なプラグインプロジェクト構造を生成します。

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

# ビルドしたプラグインをPMMPサーバーに配置
make deploy

# PMMPサーバーを起動
make run
```

### プロジェクトのクリーンアップ

```bash
make clean
```

## ディレクトリ構造

- `/.devcontainer` - Docker開発環境の設定
- `/scripts` - 各種ユーティリティスクリプト
- `/src` - プラグインのソースコード
- `/builds` - ビルドされたPHARファイル

## その他の情報

- `.editorconfig` - エディタ共通設定
- `.pre-commit-config.yaml` - git pre-commitフック設定
- `.php-cs-fixer.dist.php` - コードスタイル設定
- `phpstan.neon` - 静的解析設定
