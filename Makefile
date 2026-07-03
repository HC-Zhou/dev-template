APP_NAME=dev-template
API_DIR=api
WEB_DIR=web
DOCKER_DIR=docker
COMPOSE_FILE=$(DOCKER_DIR)/compose.yaml
COMPOSE_PROJECT=$(APP_NAME)-dev

.DEFAULT_GOAL := help

.PHONY: dev-setup prepare-api prepare-web prepare-docker dev dev-api dev-web check format test build-api build-web docker-up docker-down compose-generate compose-up compose-down clean help

dev-setup: prepare-docker prepare-api prepare-web
	@echo "Development environment is ready."

prepare-docker:
	@cp -n $(DOCKER_DIR)/.env.example $(DOCKER_DIR)/.env 2>/dev/null || true

prepare-api:
	@cp -n $(API_DIR)/.env.example $(API_DIR)/.env 2>/dev/null || true
	@cd $(API_DIR) && uv sync --dev

prepare-web:
	@cp -n $(WEB_DIR)/.env.example $(WEB_DIR)/.env.local 2>/dev/null || true
	@cd $(WEB_DIR) && corepack enable && corepack pnpm install

docker-up: prepare-docker
	@dev/start-docker-compose

docker-down:
	@dev/stop-docker-compose

compose-generate:
	@docker/generate-compose

compose-up: prepare-docker compose-generate
	@cd $(DOCKER_DIR) && docker compose --env-file .env -f compose.yaml -p $(APP_NAME) up -d --build

compose-down:
	@cd $(DOCKER_DIR) && docker compose --env-file .env -f compose.yaml -p $(APP_NAME) down

dev:
	@$(MAKE) -j2 dev-api dev-web

dev-api:
	@dev/start-api

dev-web:
	@dev/start-web

format:
	@dev/reformat

check:
	@dev/check

test:
	@dev/test

build-api:
	@docker build -f $(API_DIR)/Dockerfile -t $(APP_NAME)-api:local .

build-web:
	@docker build -f $(WEB_DIR)/Dockerfile -t $(APP_NAME)-web:local .

clean:
	@rm -rf $(API_DIR)/.venv $(WEB_DIR)/node_modules $(WEB_DIR)/.next

help:
	@echo "Development:"
	@echo "  make dev-setup    Prepare env files and install dependencies"
	@echo "  make docker-up    Start local middleware"
	@echo "  make compose-up   Start full Docker stack"
	@echo "  make dev          Start API and web dev servers"
	@echo ""
	@echo "Quality:"
	@echo "  make format       Format API and web"
	@echo "  make check        Run lint and type checks"
	@echo "  make test         Run tests"
	@echo ""
	@echo "Build:"
	@echo "  make build-api    Build API image"
	@echo "  make build-web    Build web image"
