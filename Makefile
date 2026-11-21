.PHONY: setup up build down logs db reset-db shell test-e2e test-smoke

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

test-e2e:
	@echo "Executando suíte completa de testes E2E com Playwright..."
	@npx playwright test

test-smoke:
	@echo "Executando testes E2E seguros (Smoke Tests - Somente Leitura)..."
	@npx playwright test --grep @smoke

help:
	@echo "Comandos disponíveis:"
	@echo "  make setup      - Configuração inicial completa"
	@echo "  make up         - Sobe os containers"
	@echo "  make build      - Rebuilda os containers"
	@echo "  make down       - Para os containers"
	@echo "  make logs       - Mostra logs em tempo real"
	@echo "  make db         - Roda seeds do banco"
	@echo "  make reset-db   - Reseta o banco completamente"
	@echo "  make shell      - Abre shell no container"
	@echo "  make test-e2e   - Executa suíte completa de testes E2E"
	@echo "  make test-smoke - Executa testes seguros (Smoke / Somente Leitura)"
