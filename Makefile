.DEFAULT_GOAL := help

build: ## builds development environment with sail
	composer install
	./vendor/bin/sail up -d --build
	./vendor/bin/sail artisan key:generate
	./vendor/bin/sail artisan migrate
	./vendor/bin/sail npm install
	./vendor/bin/sail npm run build

update: ## updates from git and refreshes the containers
	git pull origin HEAD
	./vendor/bin/sail composer install
	./vendor/bin/sail artisan migrate
	./vendor/bin/sail npm install
	./vendor/bin/sail npm run build

remove: ## removes current containers
	./vendor/bin/sail stop $(docker ps -a -q)
	./vendor/bin/sail rm $(docker ps -a -q)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
