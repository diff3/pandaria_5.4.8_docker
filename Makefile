# Makefile for Pandaria 5.4.8 Utility
MAKEFLAGS += --silent
# --- Load environment variables ---
ifneq ("$(wildcard .env)","")
    include .env
    export $(shell sed -n 's/^\([^#]\+\)=.*/\1/p' .env)
endif

DOCKER_COMPOSE := docker compose
UTILITY := utility

# Telnet settings (fallbacks if missing)
TELNET_HOST ?= $(REALM_ADDRESS)
TELNET_PORT ?= $(RA_PORT)

# Automatically include DB container unless using an external DB
DB_PROFILES :=
ifeq ($(EXTERNAL_DB),false)
    DB_PROFILES := --profile db
endif

.DEFAULT_GOAL := help

help:
	@echo "Available commands:"
	@echo ""
	@echo "=== Build & Setup ==="
	@echo "  make fetch_source        - Clone source code if missing, or pull latest updates if already present"
	@echo "  make build               - Build the utility container"
	@echo "  make build-nocache       - Build the utility container without cache"
	@echo "  make compile             - Compile the server (SkyFire/Pandaria)"
	@echo "  make configure           - Generate new authserver/worldserver configs"
	@echo "  make extract_data        - Extract maps, vmaps, and mmaps from WoW client"
	@echo "  make install             - Full installation (compile, extract, setup DB, start servers)"
	@echo ""
	@echo "=== Database Management ==="
	@echo "  make setup_db            - Initialize, populate, update, and finalize all databases"
	@echo "  make init_db             - Initialize MySQL/MariaDB databases (drop & recreate)"
	@echo "  make populate_db         - Populate databases with base and latest world data"
	@echo "  make update_db           - Update databases with latest SQL data"
	@echo "  make finalize_db         - Update auth with user and realm info"
	@echo "  make normalize_sql       - Normalize database names in base SQL files"
	@echo "  make backup_db           - Backup all Pandaria databases"
	@echo "  make restore_db          - Restore all Pandaria databases from backups"
	@echo "  make apply_sql           - Apply SQL files from custom_sql/misc (all or a specific file via FILE=<name>)"
	@echo ""
	@echo "=== Server Operations ==="
	@echo "  make start               - Start all containers (includes DB unless EXTERNAL_DB=true)"
	@echo "  make stop                - Stop all containers"
	@echo "  make restart             - Restart all containers"
	@echo "  make logs                - Follow logs for all containers"
	@echo "  make telnet              - Connect to RA port via telnet"
	@echo ""
	@echo "=== Client & Config Management ==="
	@echo "  make configure_client     - Configure WoW client (realmlist.wtf + Config.wtf)"
	@echo "  make apply_custom_config  - Apply custom config(s) from /app/custom (use FILE=<file> to run only one)"
	@echo ""
	@echo "=== Maintenance & Cleanup ==="
	@echo "  make down                - Stop and remove all containers (preserve volumes)"
	@echo "  make uninstall           - Remove containers, volumes, DB data, and images"
	@echo "  make clean               - Remove dangling containers and images"
	@echo ""
	@echo "=== Debug & Shell ==="
	@echo "  make shell               - Start a shell inside the utility container"
	@echo "  make check               - check if dependencies are met."


# --- Build and Compile ---
build:
	$(DOCKER_COMPOSE) build $(UTILITY)

build-nocache:
	$(DOCKER_COMPOSE) build --no-cache $(UTILITY)

compile:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) compile

configure:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) configure

extract_data:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) extract_data

# --- Database Operations $(DOCKER_COMPOSE) run --rm $(UTILITY) init_db ---
init_db:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh templates init_db_template.sql

populate_db:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) populate_db

update_db:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) update_db

# --- bk 	$(DOCKER_COMPOSE) run --rm $(UTILITY) finalize_db ---

finalize_db:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh templates auth_update_template.sql

# -- 	$(DOCKER_COMPOSE) run --rm $(UTILITY) setup_db
setup_db:
	@echo "Initializing databases..."
	$(MAKE) init_db
	@echo "Populating databases..."
	$(MAKE) populate_db
	@echo "Updating databases..."
	$(MAKE) update_db
	@echo "Finalizing setup..."
	$(MAKE) finalize_db
	@echo "Database setup complete."

normalize_sql:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) normalize_sql

backup_db:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/backup_db.sh

restore_db:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/restore_db.sh

# --- Server Operations ---
start:
	@echo "Starting services... (DB container: $$(if [ "$(EXTERNAL_DB)" = "true" ]; then echo "disabled (external DB)"; else echo "enabled"; fi))"
	$(DOCKER_COMPOSE) up -d $(DB_PROFILES)

stop:
	$(DOCKER_COMPOSE) stop

restart:
	$(DOCKER_COMPOSE) restart

logs:
	$(DOCKER_COMPOSE) logs -f

down:
	$(DOCKER_COMPOSE) down

# $(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/uninstall_db.sh || true
uninstall:
	@echo "Removing all containers, volumes, and images..."
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh templates uninstall_db_template.sql
	$(DOCKER_COMPOSE) down -v --rmi all --remove-orphans
	docker system prune -af

# --- Misc ---
shell:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/bash

clean:
	docker image prune -f

telnet:
	@echo "Connecting to RA console at $(TELNET_HOST):$(TELNET_PORT)..."
	@telnet $(TELNET_HOST) $(TELNET_PORT)

configure_client:
	@sh misc/configure_client.sh '$(WOW_PATH)' '$(WOW_LOCALE)' '$(REALM_ADDRESS)'

# --- Apply custom configs (for worldserver/authserver) ---
apply_custom_config:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/apply_custom_config.sh $(FILE)

# --- Combined Install ---
install: fetch_source build compile extract_data setup_db configure start
	@echo "Installation complete. All services are running."

apply_sql:
# Default directory if not provided
DIR ?= 
FILE ?=
DB ?=

apply_sql:
	@if [ -n "$(FILE)" ]; then \
		$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh "$(DIR)" "$(FILE)" "$(DB)"; \
	else \
		$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh "$(DIR)" "" "$(DB)"; \
	fi
	

# --- Dependency Check & Install ---
check:
	@echo "Checking required dependencies..."
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "Error: docker is not installed. Please install it."; exit 1; \
	fi
	@if ! docker compose version >/dev/null 2>&1; then \
		echo "Error: docker compose is not installed or configured."; exit 1; \
	fi
	@if ! command -v git >/dev/null 2>&1; then \
		echo "Error: git is not installed. Please install it."; exit 1; \
	fi

	@if ! command -v telnet >/dev/null 2>&1; then \
		echo "Error: telnet is not installed. Please install it."; exit 1; \
	fi
	@echo "All dependencies are present."

# Fetch the source code if not already present
fetch_source:
	@if [ ! -d "src/pandaria_5.4.8/.git" ]; then \
		echo "Cloning Pandaria 5.4.8 source..."; \
		git clone https://github.com/alexkulya/pandaria_5.4.8 src/pandaria_5.4.8; \
	else \
		echo "Updating Pandaria 5.4.8 source..."; \
		cd src/pandaria_5.4.8 && git pull --rebase; \
	fi