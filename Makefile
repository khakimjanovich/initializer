.DEFAULT_GOAL := run

# Default ports
DEFAULT_APP_PORT := 80
DEFAULT_MYSQL_PORT := 3306
DEFAULT_PHP_PORT := 9000
DEFAULT_REDIS_PORT := 6379
DEFAULT_NPM_PORT1 := 3000
DEFAULT_NPM_PORT2 := 3001
DEFAULT_NPM_PORT3 := 5173

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
	read -p "Enter MySQL port (default: 3306): " MYSQL_PORT; \
	MYSQL_PORT=$${MYSQL_PORT:-$(DEFAULT_MYSQL_PORT)}; \
	read -p "Enter PHP port (default: 9000): " PHP_PORT; \
	PHP_PORT=$${PHP_PORT:-$(DEFAULT_PHP_PORT)}; \
	read -p "Enter Redis port (default: 6379): " REDIS_PORT; \
	REDIS_PORT=$${REDIS_PORT:-$(DEFAULT_REDIS_PORT)}; \
	read -p "Enter NPM port 1 (default: 3000): " NPM_PORT1; \
	NPM_PORT1=$${NPM_PORT1:-$(DEFAULT_NPM_PORT1)}; \
	read -p "Enter NPM port 2 (default: 3001): " NPM_PORT2; \
	NPM_PORT2=$${NPM_PORT2:-$(DEFAULT_NPM_PORT2)}; \
	read -p "Enter NPM port 3 (default: 5173): " NPM_PORT3; \
	NPM_PORT3=$${NPM_PORT3:-$(DEFAULT_NPM_PORT3)}; \
	\
	sed -e "s/80:80/$${APP_PORT}:80/" \
		-e "s/3306:3306/$${MYSQL_PORT}:3306/" \
		-e "s/9000:9000/$${PHP_PORT}:9000/" \
		-e "s/6379:6379/$${REDIS_PORT}:6379/" \
		-e "s/3000:3000/$${NPM_PORT1}:3000/" \
		-e "s/3001:3001/$${NPM_PORT2}:3001/" \
		-e "s/5173:5173/$${NPM_PORT3}:5173/" \
		docker-compose.yml.template > docker-compose.yml
	@docker compose run --rm composer create-project laravel/laravel .
create:check-src set-ports

set-up:set-ports
	@test -f ./src/.env || cp ./src/.env.example ./src/.env
	@docker compose run --rm composer install
	@docker compose run --rm artisan migrate
	@docker compose run --rm artisan key:generate
	@docker compose run --rm npm install
	@docker compose run --rm npm run build
	@docker compose up -d

run:
	@docker compose run --rm composer install
	@docker compose run --rm artisan migrate
	@docker compose run --rm artisan key:generate
	@docker compose run --rm npm install
	@docker compose run --rm npm run build
	@docker compose up -d
clean:
	@docker compose down
	@rm -f docker-compose.yml

update:
	git pull origin HEAD
	@docker compose run --rm composer install
	@docker compose run --rm artisan migrate
	@docker compose run --rm npm install
	@docker compose run --rm npm run build
	@docker compose up --build -d