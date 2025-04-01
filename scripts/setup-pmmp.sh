#!/bin/bash

# 引数のバリデーションを実施
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ]; then
    echo "エラー: 必須パラメータが不足しています。"
    echo "使用法: $0 <PMMP_VERSION> <PHP_BUILD_VERSION> <ARCH> <OS> <BASE_PATH>"
    echo "例: $0 5.27.0 pm5-php-8.3 x86_64 Windows /pmmp"
    exit 1
fi

# コマンドライン引数を取得
PMMP_VERSION="$1"
PHP_BUILD_VERSION="$2"
ARCH="$3"
OS="$4"
BASE_PATH="$5"

echo "セットアップ構成:"
echo "- PMMP バージョン: ${PMMP_VERSION}"
echo "- PHP ビルドバージョン: ${PHP_BUILD_VERSION}"
echo "- アーキテクチャ: ${ARCH}"
echo "- OS: ${OS}"
echo "- インストールパス: ${BASE_PATH}"

# ディレクトリが存在する場合は終了
if [ -d "$BASE_PATH" ]; then
    echo "${BASE_PATH}ディレクトリが既に存在します。セットアップをスキップします。"
    exit 0
fi

# PMMPのディレクトリを作成
mkdir -p "$BASE_PATH"

# ダウンロードの共通関数
download_file() {
    local url="$1"
    local output_path="$2"
    local description="$3"

    echo "${description}をダウンロード中: ${url}"

    # 最大3回リトライする
    for i in {1..3}; do
        if curl -L -A "Mozilla/5.0" -o "${output_path}" "${url}"; then
            echo "${description}のダウンロードが完了しました"
            # ファイルサイズをチェック（0バイト以上であること）
            if [ -s "${output_path}" ]; then
                return 0  # 成功
            else
                echo "警告: ダウンロードしたファイルが空です。リトライします... (${i}/3)"
            fi
        else
            echo "警告: ダウンロードに失敗しました。リトライします... (${i}/3)"
        fi

        # 少し待ってからリトライ
        sleep 2
    done

    echo "エラー: ${description}のダウンロードに失敗しました。"
    return 1  # 失敗
}

# PocketMine-MP をダウンロード
echo "PocketMine-MP ${PMMP_VERSION} をダウンロード中..."
if ! download_file "https://github.com/pmmp/PocketMine-MP/releases/download/${PMMP_VERSION}/PocketMine-MP.phar" "${BASE_PATH}/PocketMine-MP.phar" "PocketMine-MP ${PMMP_VERSION}"; then
    echo "PocketMine-MPのダウンロードに失敗しました。セットアップを中止します。"
    exit 1
fi

# OSに応じて起動スクリプトをダウンロード
if [ "$OS" == "Windows" ]; then
    if ! download_file "https://github.com/pmmp/PocketMine-MP/releases/download/${PMMP_VERSION}/start.cmd" "${BASE_PATH}/start.cmd" "公式Windows用start.cmdスクリプト"; then
        echo "起動スクリプトのダウンロードに失敗しました。セットアップを中止します。"
        exit 1
    fi
else
    if ! download_file "https://github.com/pmmp/PocketMine-MP/releases/download/${PMMP_VERSION}/start.sh" "${BASE_PATH}/start.sh" "公式Linux用start.shスクリプト"; then
        echo "起動スクリプトのダウンロードに失敗しました。セットアップを中止します。"
        exit 1
    fi
    chmod +x "${BASE_PATH}/start.sh"
fi

# PHPバイナリをダウンロード (Windows と Linux 両方)
echo "PHPバイナリをダウンロードして展開中..."
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

if [ "$OS" == "Windows" ]; then
    # Windows用PHPバイナリの処理
    # PHPバイナリ用のディレクトリを作成
    mkdir -p "${BASE_PATH}/bin/php"

    # PHPバイナリのダウンロードURL (PHP バージョンを抽出)
    PHP_VERSION="${PHP_BUILD_VERSION#*-php-}"
    PHP_URL="https://github.com/pmmp/PHP-Binaries/releases/download/${PHP_BUILD_VERSION}-latest/PHP-${PHP_VERSION}-Windows-${ARCH}-PM5.zip"

    echo "PHPバイナリをダウンロード中: $PHP_URL"
    if ! download_file "$PHP_URL" "php.zip" "Windows用PHPバイナリ"; then
        echo "PHPバイナリのダウンロードに失敗しました。セットアップを中止します。"
        exit 1
    fi

    # ZIPファイルのサイズを確認
    ZIP_SIZE=$(stat -c %s php.zip 2>/dev/null || stat -f %z php.zip 2>/dev/null)
    echo "ダウンロードしたファイルのサイズ: ${ZIP_SIZE} bytes"

    if [ -z "$ZIP_SIZE" ] || [ "$ZIP_SIZE" -lt 1000 ]; then
        echo "ダウンロードしたファイルが小さすぎます。破損している可能性があります。"
        echo "正しいURLを確認してください: $PHP_URL"
        echo "ダウンロードしたファイルのサイズ: $(du -h php.zip | cut -f1)"
        exit 1
    fi

    # 一時ディレクトリに展開 (テスト付き)
    echo "ZIPアーカイブを解凍テスト中..."
    if ! unzip -t php.zip > /dev/null; then
        echo "ZIPファイルのテストに失敗しました。破損している可能性があります。"
        echo "正しいURLを確認してください: $PHP_URL"
        exit 1
    fi

    echo "ZIPアーカイブを解凍中..."
    mkdir -p ./extracted
    unzip -q php.zip -d ./extracted

    # 実際の構造を確認し、適切にファイルを移動
    if [ -d "./extracted/bin/php" ]; then
        cp -r ./extracted/bin/php/* "${BASE_PATH}/bin/php/"
    elif [ -d "./extracted/php" ]; then
        cp -r ./extracted/php/* "${BASE_PATH}/bin/php/"
    else
        cp -r ./extracted/* "${BASE_PATH}/bin/php/"
    fi

    # クリーンアップ
    rm -rf ./extracted php.zip

    # PHPのバイナリ構造を確認
    if [ ! -f "${BASE_PATH}/bin/php/php.exe" ]; then
        echo "警告: 予想される場所にPHPバイナリが見つかりませんでした。"
        echo "利用可能なファイル:"
        find "${BASE_PATH}" -type f -name "*.exe" | sort
        echo "手動での調整が必要かもしれません。"
    else
        echo "PHPバイナリが正常にインストールされました。"
    fi
else
    # Linux用PHPバイナリの処理
    PHP_VERSION="${PHP_BUILD_VERSION#*-php-}"
    PHP_URL="https://github.com/pmmp/PHP-Binaries/releases/download/${PHP_BUILD_VERSION}-latest/PHP-${PHP_VERSION}-${OS}-${ARCH}-PM5.tar.gz"

    echo "PHPバイナリをダウンロード中: $PHP_URL"
    if ! download_file "$PHP_URL" "php.tar.gz" "Linux用PHPバイナリ"; then
        echo "PHPバイナリのダウンロードに失敗しました。セットアップを中止します。"
        exit 1
    fi

    # 一時ディレクトリに展開
    mkdir -p ./extracted
    tar -xzf php.tar.gz -C ./extracted

    # PHPバイナリディレクトリの構造を整理
    mkdir -p "${BASE_PATH}/bin/php7/bin"

    # 展開されたディレクトリ構造を確認
    if [ -d "./extracted/bin/bin/php7" ]; then
        # 二重binディレクトリの場合
        echo "ディレクトリ構造を修正中 (二重bin構造)..."
        cp -r ./extracted/bin/bin/php7/* "${BASE_PATH}/bin/php7/"
    elif [ -d "./extracted/bin/php7" ]; then
        # 正しい構造の場合
        echo "ディレクトリ構造を修正中 (標準構造)..."
        cp -r ./extracted/bin/php7/* "${BASE_PATH}/bin/php7/"
    else
        # その他のケース
        echo "ディレクトリ構造を修正中 (その他の構造)..."
        # 先にフォルダを整理するために全ファイルの場所を特定
        PHP_BIN=$(find ./extracted -name php -type f)
        if [ -n "$PHP_BIN" ]; then
            PHP_DIR=$(dirname "$PHP_BIN")
            echo "PHPバイナリを発見: $PHP_BIN"
            # PHPバイナリを適切な場所にコピー
            cp -r "$PHP_DIR"/* "${BASE_PATH}/bin/php7/bin/"
            # 必要なライブラリをコピー
            find ./extracted -name "*.so" -exec cp {} "${BASE_PATH}/bin/php7/lib/" \;
        else
            echo "警告: PHPバイナリが見つかりませんでした"
            # 全てのファイルをコピー
            cp -r ./extracted/* "${BASE_PATH}/bin/"
        fi
    fi

    # opcache.soのフルパスを設定
    OPCACHE_SO=$(find "${BASE_PATH}" -name opcache.so 2>/dev/null || true)
    if [ -n "$OPCACHE_SO" ]; then
        echo "opcache.soのパスを設定中: $OPCACHE_SO"
        PHP_INI_PATH=$(find "${BASE_PATH}" -name php.ini)
        if [ -n "$PHP_INI_PATH" ]; then
            sed -i "s|^zend_extension=opcache.so|zend_extension=${OPCACHE_SO}|" "$PHP_INI_PATH"
        fi
    fi

    # xdebug.soのフルパスを設定
    XDEBUG_SO=$(find "${BASE_PATH}" -name xdebug.so 2>/dev/null || true)
    if [ -n "$XDEBUG_SO" ]; then
        echo "xdebug.soのパスを設定中: $XDEBUG_SO"
        PHP_INI_PATH=$(find "${BASE_PATH}" -name php.ini)
        if [ -n "$PHP_INI_PATH" ]; then
            sed -i "s|^;zend_extension=xdebug.so|zend_extension=${XDEBUG_SO}|" "$PHP_INI_PATH"
        fi
    fi

    # クリーンアップ
    rm -f php.tar.gz
    rm -rf ./extracted

    echo "Linuxの場合、PHPバイナリの権限設定中..."
    find "${BASE_PATH}" -type f -name "php" -exec chmod +x {} \;
    find "${BASE_PATH}" -type f -name "php*" -exec chmod +x {} \;

    # PHPバイナリのパスを確認
    if [ -f "${BASE_PATH}/bin/php7/bin/php" ]; then
        echo "PHPバイナリが正しい場所に配置されています: ${BASE_PATH}/bin/php7/bin/php"

        # シンボリックリンクの作成
        ln -sf "${BASE_PATH}/bin/php7/bin/php" "${BASE_PATH}/bin/php" || true
    else
        PHP_PATH=$(find "${BASE_PATH}" -name php -type f | head -n 1)
        echo "警告: PHPバイナリが標準以外の場所にあります: $PHP_PATH"
        # ディレクトリ構造を出力して確認
        find "${BASE_PATH}" -type f -name "php" -o -name "*.so" | sort
    fi
fi

cd -
rmdir $TEMP_DIR


echo "所有者を変更中..."
chown -R vscode:vscode "${BASE_PATH}" || true

echo "PMMPセットアップ完了。サーバーを起動するには 'make run' を実行してください。"
