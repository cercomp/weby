#!/bin/bash
set -e

echo "⚠️  ESTE SCRIPT É APENAS PARA DESENVOLVIMENTO LOCAL"
echo ""
echo "======================================"
echo " WEBY - LOCAL DEVELOPMENT ENV SETUP"
echo "======================================"

if [ ! -f ".env" ]; then
  echo "Criando .env para desenvolvimento..."
  cp .env.dev.example .env
else
  echo ".env já existe, mantendo configuração atual..."
fi

echo "Subindo containers..."
docker compose -f docker-compose.dev.yml up --build -d

echo "Aguardando banco subir..."
until docker compose -f docker-compose.dev.yml exec db pg_isready -U weby >/dev/null 2>&1; do
  echo "  Banco ainda não está pronto, aguardando..."
  sleep 2
done

echo "Configurando banco de dados..."
docker compose -f docker-compose.dev.yml exec weby rake db:environment:set RAILS_ENV=development
docker compose -f docker-compose.dev.yml exec weby rake db:drop db:create
docker compose -f docker-compose.dev.yml exec weby rake db:schema:load
docker compose -f docker-compose.dev.yml exec weby rake db:migrate
docker compose -f docker-compose.dev.yml exec weby rake db:seed

echo ""
echo "✅ Ambiente de desenvolvimento pronto!"
echo "🌐 Acesse: http://localhost:3000"
