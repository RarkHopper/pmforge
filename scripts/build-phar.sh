#!/bin/bash
set -e

# Disable phar.readonly if needed
PHP_INI=$(php -r "echo php_ini_loaded_file();")
if [ -z "$PHP_INI" ]; then
  echo "Warning: Could not detect php.ini location"
  PHP_CMD="php -d phar.readonly=0 ./scripts/build-phar.php"
else
  echo "Using PHP ini file: $PHP_INI"
  PHP_CMD="php -d phar.readonly=0 ./scripts/build-phar.php"
fi

# Check if yaml extension is available, if not try to load it
if ! php -m | grep -q yaml; then
  echo "Warning: YAML extension not loaded. Attempting to load it dynamically."
  PHP_CMD="php -d extension=yaml -d phar.readonly=0 ./scripts/build-phar.php"
fi

echo "Building plugin phar..."
$PHP_CMD

if [ $? -ne 0 ]; then
  echo "Failed to build phar. Make sure yaml extension is installed and phar.readonly=0 is set."
  exit 1
fi
