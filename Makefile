.PHONY: init-plugin clean
init-plugin:
	- @make clean
	- bash ./scripts/init-plugin.sh

clean:
	- rm -rf ./src/*
	- rm plugin.yml
