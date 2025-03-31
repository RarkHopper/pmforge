.PHONY: init-plugin clean analyse fix check

init-plugin:
	- @make clean
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
