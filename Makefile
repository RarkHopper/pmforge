.PHONY: init-plugin clean analyse fix check build

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
