#!/bin/bash
set -e

echo "Add command aliases to .bashrc..."
bash .devcontainer/register-aliases.sh

echo "Install composer dependencies..."
composer install --no-interaction --prefer-dist

echo "Post-creation setup completed successfully."
