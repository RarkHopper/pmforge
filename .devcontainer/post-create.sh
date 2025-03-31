#!/bin/bash
set -e

bash .devcontainer/register-aliases.sh

pre-commit install

composer install
