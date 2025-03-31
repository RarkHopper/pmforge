#!/bin/bash
set -e

echo "Add command aliases to .bashrc..."
bash .devcontainer/register-aliases.sh

# Install pre-commit hooks
pre-commit install

# Composer setup (if you have a composer.json)
if [ -f "composer.json" ]; then
    composer install
fi

# PHP Intelephense setup
code --install-extension bmewburn.vscode-intelephense-client --force

echo "DevContainer setup complete!"
