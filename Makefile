DB ?= postgres://postgres:postgres@localhost:5432/testdb
COMPOSE = docker compose -f tooling/docker-compose.yml

db-up:
	$(COMPOSE) up -d

db-down:
	$(COMPOSE) down -v

db-reset: db-up
	-psql "$(DB)" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
	@echo "Schema reset."

db-init:
	psql "$(DB)" -f schema/001_init.sql
	psql "$(DB)" -f schema/002_sample_data.sql

run-queries:
	psql "$(DB)" -f queries/01_client_sums.sql
	psql "$(DB)" -f queries/02_category_children.sql
	psql "$(DB)" -f queries/03_category_path_cte.sql
