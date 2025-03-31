#!/bin/bash
set -e

prompt() {
  read -r -p "$1: " value
  if [ -z "$value" ] && [ -n "$3" ]; then
    eval "$2=\$3"
  else
    eval "$2=\$value"
  fi
}

# プラグイン情報の収集
prompt "プラグイン名" plugin_name

# ディレクトリ作成のためにプラグイン名を整形（スペースをアンダースコアに置換、特殊文字を削除）
plugin_name_sanitized=$(echo "$plugin_name" | tr ' ' '_' | sed 's/[^a-zA-Z0-9_]//g')

# プラグイン名からデフォルトのメインクラス名を生成（最初の文字を大文字にしてPlugin接尾辞を追加）
first_char=$(echo "${plugin_name_sanitized:0:1}" | tr '[:lower:]' '[:upper:]')
rest_of_name="${plugin_name_sanitized:1}"
default_main_class="${first_char}${rest_of_name}Plugin"

prompt "バージョン (例: 1.0.0)" version "1.0.0"
prompt "APIバージョン (デフォルト: 5.0.0)" api_version "5.0.0"
prompt "作者" author
prompt "説明" description
prompt "メインクラス (デフォルト: ${default_main_class})" main_class "$default_main_class"

# ディレクトリ名用に小文字に変換
author_lower="${author,,}"
plugin_name_lower="${plugin_name_sanitized,,}"

# プラグインのディレクトリ構造を作成
mkdir -p "src/$author_lower/$plugin_name_lower"

# 名前空間を設定
namespace="$author_lower\\$plugin_name_lower"

# メインクラスファイルを作成（PHPテンプレートを使用）
cat > "src/$author_lower/$plugin_name_lower/$main_class.php" <<EOL
<?php
declare(strict_types=1);

namespace $namespace;

use pocketmine\plugin\PluginBase;
use pocketmine\utils\TextFormat as TF;

class $main_class extends PluginBase {
    public function onEnable(): void {
        \$this->getLogger()->info(TF::GREEN . "$plugin_name has been enabled!");
    }

    public function onDisable(): void {
        \$this->getLogger()->info(TF::RED . "$plugin_name has been disabled!");
    }
}
EOL

# ルートディレクトリにplugin.ymlファイルを作成
cat > plugin.yml <<EOL
name: $plugin_name
version: $version
api: $api_version
author: $author
description: $description
main: $namespace\\$main_class
EOL

# composer.jsonの名前とオートロード設定を更新
namespace_prefix="${author_lower}\\${plugin_name_lower}\\"
namespace_path="src/$author_lower/$plugin_name_lower"
composer_name="${author_lower}/${plugin_name_lower}"

# 一時ファイルを使用してcomposer.jsonを更新
if command -v jq &> /dev/null; then
  jq --arg name "$composer_name" \
     --arg prefix "$namespace_prefix" \
     --arg path "$namespace_path" \
     '.name = $name | .autoload."psr-4" = {} | .autoload."psr-4"[$prefix] = $path' \
     composer.json > composer.json.tmp

  # jqコマンドが成功したか確認
  if [ $? -eq 0 ]; then
    mv composer.json.tmp composer.json
    echo "Composerの設定が正常に更新されました。"
  else
    echo "警告: composer.jsonの更新中にエラーが発生しました。"
  fi
else
  # jqが利用できない場合のフォールバック
  echo "警告: jqが利用できません。composer.jsonを自動的に更新できませんでした。"
  echo "composer.jsonファイルを手動で以下のように更新してください:"
  echo "\"name\": \"$composer_name\""
  echo "そして、psr-4セクションを次のように置き換えてください:"
  echo "\"psr-4\": { \"$namespace_prefix\": \"$namespace_path\" }"
fi

composer dump-autoload

echo "プラグインプロジェクトの初期化が完了しました。"
echo "plugin.ymlがルートディレクトリに作成されました。"
echo "メインクラスファイル: src/$author_lower/$plugin_name_lower/$main_class.php"
