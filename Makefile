.DEFAULT_GOAL := run

# Default ports
DEFAULT_APP_PORT := 80
DEFAULT_PHP_PORT := 9000

check-src:
	@if [ ! -d "src" ]; then \
		echo "src folder does not exist. Creating..."; \
		mkdir src; \
	else \
		echo "src folder already exists. Doing nothing."; \
	fi

set-ports:
	@read -p "Enter app port (default: 80): " APP_PORT; \
	APP_PORT=$${APP_PORT:-$(DEFAULT_APP_PORT)}; \
	read -p "Enter PHP port (default: 9000): " PHP_PORT; \
	PHP_PORT=$${PHP_PORT:-$(DEFAULT_PHP_PORT)}; \
	\
	sed -e "s/80:80/$${APP_PORT}:80/" \
		-e "s/9000:9000/$${PHP_PORT}:9000/" \
		docker-compose.yml.template > docker-compose.yml

create:check-src set-ports
	@docker compose run --rm composer create-project laravel/laravel .

set-up:set-ports
	@test -f ./src/.env || cp ./src/.env.example ./src/.env
	@docker compose run --rm composer install
	@docker compose run --rm artisan migrate
	@docker compose run --rm artisan key:generate
	@docker compose up -d --remove-orphans --build

run:set-ports
	@docker compose run --rm composer install
	@docker compose run --rm artisan migrate
	@docker compose run --rm artisan key:generate
	@docker compose up -d
clean:
	@docker compose down
	@rm -f docker-compose.yml

update:
	git pull origin HEAD
	@docker compose run --rm composer install
	@docker compose run --rm artisan migrate
	@docker compose up --build -d