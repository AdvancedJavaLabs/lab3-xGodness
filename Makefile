build:
	@cd sales-analyzer && ./gradlew build

up: down
	@docker compose --env-file hadoop.env up --build

down:
	@docker compose down
