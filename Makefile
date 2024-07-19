.DEFAULT_GOAL := help

build: ## build develoment environment with sail
	if ! [ -f .env ];then cp .env.example .env;fi
	composer install
	./vendor/bin/sail up -d --build
	./vendor/bin/sail artisan key:generate
	./vendor/bin/sail artisan migrate
	npm install
	npm run build


.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

