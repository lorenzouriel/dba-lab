SHELL := /bin/bash
COMPOSE := docker compose
SQLCMD := /opt/mssql-tools18/bin/sqlcmd
-include .env
export

.PHONY: help init up down restart logs sql ps seed ha ai pull-model trust-ca backup nuke

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

init: ## first-time setup: .env + host dir ownership for uid 10001
	@test -f .env || cp .env.example .env
	@mkdir -p restore backups certs
	sudo chown -R 10001:0 backups restore certs
	sudo chmod 775 backups
	@echo "edit .env, then: make up"

up: ## build and start sql1 + bootstrap
	$(COMPOSE) up -d --build sql1
	$(COMPOSE) up bootstrap

down: ## stop everything (volumes survive)
	$(COMPOSE) --profile ha --profile ai down

restart: ## restart sql1
	$(COMPOSE) restart sql1

ps: ## container status
	$(COMPOSE) ps

logs: ## tail sql1 errorlog
	$(COMPOSE) logs -f sql1

sql: ## interactive sqlcmd session on sql1
	$(COMPOSE) exec sql1 $(SQLCMD) -S localhost -U sa -P "$(MSSQL_SA_PASSWORD)" -C

seed: ## restore SEED_BAK from ./restore into SEED_DB
	$(COMPOSE) --profile seed run --rm seed

ha: ## bring up the second instance for AG / replication labs
	$(COMPOSE) --profile ha up -d sql2

ai: ## bring up Ollama + Caddy (TLS) for embeddings
	$(COMPOSE) --profile ai up -d

pull-model: ## download the embedding model into Ollama
	$(COMPOSE) exec ollama ollama pull nomic-embed-text

trust-ca: ## export Caddy's root CA and rebuild sql1 to trust it
	$(COMPOSE) cp caddy:/data/caddy/pki/authorities/local/root.crt ./certs/caddy-root.crt
	$(COMPOSE) up -d --build sql1

backup: ## BACKUP DATABASE $(DB) to ./backups
	$(COMPOSE) exec sql1 $(SQLCMD) -S localhost -U sa -P "$(MSSQL_SA_PASSWORD)" -C -b -Q \
	  "BACKUP DATABASE [$(DB)] TO DISK='/var/opt/mssql/backups/$(DB).bak' WITH INIT, COMPRESSION, STATS=10"

nuke: ## destroy containers AND volumes — full reset
	$(COMPOSE) --profile ha --profile ai down -v
