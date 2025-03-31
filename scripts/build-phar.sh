#!/bin/bash
set -e

# 正しいPHPバイナリのパスを設定
PHP_BINARY="${PMMP_PHP_DIR}/bin/php7/bin/php"

# PHPバイナリが存在するか確認
if [ ! -f "$PHP_BINARY" ]; then
  echo "Error: PHP Binary not found at $PHP_BINARY"
  exit 1
fi

# Disable phar.readonly if needed
PHP_INI=$(${PHP_BINARY} -r "echo php_ini_loaded_file();")
if [ -z "$PHP_INI" ]; then
  echo "Warning: Could not detect php.ini location"
  PHP_CMD="${PHP_BINARY} -d phar.readonly=0 ./scripts/build-phar.php"
else
  echo "Using PHP ini file: $PHP_INI"
  PHP_CMD="${PHP_BINARY} -d phar.readonly=0 ./scripts/build-phar.php"
fi

# Check if yaml extension is available, if not try to load it
if ! ${PHP_BINARY} -m | grep -q yaml; then
  echo "Warning: YAML extension not loaded. Attempting to load it dynamically."
  PHP_CMD="${PHP_BINARY} -d extension=yaml -d phar.readonly=0 ./scripts/build-phar.php"
fi

echo "Building plugin phar..."
$PHP_CMD

if [ $? -ne 0 ]; then
  echo "Failed to build phar. Make sure yaml extension is installed and phar.readonly=0 is set."
  exit 1
fi
