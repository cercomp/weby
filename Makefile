.PHONY: setup up build down logs db reset-db shell

setup:
	@echo "Configurando ambiente de desenvolvimento..."
	@chmod +x scripts/dev/setup.sh
	@chmod +x scripts/dev/db.sh
	@./scripts/dev/setup.sh

up:
	@echo "Subindo containers..."
	@docker compose -f docker-compose.dev.yml up -d

build:
	@echo "Rebuildando containers..."
	@docker compose -f docker-compose.dev.yml up --build -d

down:
	@echo "Parando containers..."
	@docker compose -f docker-compose.dev.yml down

logs:
	@echo "Mostrando logs dos containers (Ctrl+C para sair)..."
	@docker compose -f docker-compose.dev.yml logs -f

db:
	@echo "Rodando seeds do banco..."
	@docker compose -f docker-compose.dev.yml exec weby rake db:seed

reset-db:
	@echo "Resetando banco de dados..."
	@chmod +x scripts/dev/db.sh
	@./scripts/dev/db.sh

shell:
	@echo "Abrindo shell no container..."
	@docker compose -f docker-compose.dev.yml exec weby bash

help:
	@echo "Comandos disponíveis:"
	@echo "  make setup     - Configuração inicial completa"
	@echo "  make up        - Sobe os containers"
	@echo "  make build     - Rebuilda os containers"
	@echo "  make down      - Para os containers"
	@echo "  make logs      - Mostra logs em tempo real"
	@echo "  make db        - Roda seeds do banco"
	@echo "  make reset-db  - Reseta o banco completamente"
	@echo "  make shell     - Abre shell no container"
