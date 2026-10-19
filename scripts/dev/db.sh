#!/bin/bash
set -e

echo "======================================"
echo " WEBY - DATABASE RESET"
echo "======================================"

echo "Resetando e configurando banco de dados..."
docker compose -f docker-compose.dev.yml exec weby rake db:drop db:create
docker compose -f docker-compose.dev.yml exec weby rake db:schema:load
docker compose -f docker-compose.dev.yml exec weby rake db:migrate
docker compose -f docker-compose.dev.yml exec weby rake db:seed

echo ""
echo "✅ Banco de dados configurado com sucesso!"
