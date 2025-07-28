# Makefile for $(PROJECT_NAME) 5.4.8 Utility
MAKEFLAGS += --silent

# --- Load environment variables ---
ifneq ("$(wildcard .env)","")
    include .env
    export $(shell sed -n 's/^\([^#]\+\)=.*/\$(EXTRACTORS)/p' .env)
endif

DOCKER_COMPOSE := docker compose
UTILITY := utility

# Telnet defaults (can override in .env)
TELNET_HOST ?= $(REALM_ADDRESS)
TELNET_PORT ?= $(RA_PORT)

# DB container profile (only runs if EXTERNAL_DB=false)
DB_PROFILES :=
DB_MODE=external
DB_SERVICE=
ifeq ($(EXTERNAL_DB),false)
    DB_PROFILES := --profile db
	DB_MODE=internal
	DB_SERVICE=db
endif

.DEFAULT_GOAL := help

help:
	@echo "Available commands:"
	@echo ""
	@echo "=== Build & Setup ==="
	@echo "  make fetch_source        - Clone or update the $(PROJECT_NAME) source code"
	@echo "  make build               - Build the utility container"
	@echo "  make build-nocache       - Build the utility container without cache"
	@echo "  make compile             - Compile the server (SkyFire/$(PROJECT_NAME))"
	@echo "  make configure           - Generate fresh authserver/worldserver configs"
	@echo "  make extract_data        - Extract maps, vmaps, and mmaps from client"
	@echo "  make install             - Full installation (build, extract, DB, start servers)"
	@echo ""
	@echo "=== Database Management ==="
	@echo "  make setup_db            - Initialize, bundle, install, and finalize all databases"
	@echo "  make bundle_db           - Build SQL bundles (base, patches, fixes, custom) into $(SQL_INSTALL_DIR)"
	@echo "  make init_db             - Drop and recreate MySQL/MariaDB databases"
	@echo "  make populate_db         - Install base SQL Gfiles from $(SQL_INSTALL_DIR)"
	@echo "  make update_db           - Apply patch SQL bundles from $(SQL_INSTALL_DIR)"
	@echo "  make fix_db              - Apply SQL fixes (bundled per DB) from $(SQL_INSTALL_DIR)"
	@echo "  make add_custom_db       - Apply custom SQL (bundled per DB) from $(SQL_INSTALL_DIR)"
	@echo "  make finalize_db         - Update auth DB with accounts and realm info"
	@echo "  make backup_db           - Backup all $(PROJECT_NAME) databases"
	@echo "  make restore_db          - Restore all $(PROJECT_NAME) databases"
	@echo "  make apply_sql           - Run SQL manually (DIR=<dir>, FILE=<file>, DB=<db>)"
	@echo ""
	@echo "=== Server Operations ==="
	@echo "  make start               - Start all containers (DB included unless EXTERNAL_DB=$(EXTERNAL_DB))"
	@echo "  make stop                - Stop all containers"
	@echo "  make restart             - Restart all containers"
	@echo "  make logs                - Follow container logs"
	@echo "  make telnet              - Connect to the RA console via telnet"
	@echo ""
	@echo "=== Config & Client ==="
	@echo "  make configure_client    - Update client realmlist and Config.wtf"
	@echo "  make apply_custom_config - Apply .conf overrides from $(CUSTOM_DIR)"
	@echo ""
	@echo "=== Cleanup & Debug ==="
	@echo "  make down                - Stop and remove all containers (volumes kept)"
	@echo "  make uninstall           - Remove containers, volumes, DB, and images"
	@echo "  make clean               - Remove dangling Docker images"
	@echo "  make shell               - Open a shell in the utility container"
	@echo "  make check               - Verify required dependencies"

# --- Build & Compile ---
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

# --- Database Operations ---
init_db:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh templates init_db_template.sql

populate_db:
	@echo "Installing base SQL files..."
	@if ls $(SQL_INSTALL_DIR)/*_base.sql >/dev/null 2>&$(EXTRACTORS); then \
		for f in $(SQL_INSTALL_DIR)/*_base.sql; do \
			echo "Applying $$f..."; \
			$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh install "$$(basename $$f)" || \
				echo "Warning: Failed to apply $$f (continuing)"; \
		done; \
	else \
		echo "Warning: No base SQL found. Run 'make bundle_db' first."; \
	fi

update_db:
	@echo "Applying SQL patch bundles..."
	@if ls $(SQL_INSTALL_DIR)/*_patches_update.sql >/dev/null 2>&$(EXTRACTORS); then \
		for f in $(SQL_INSTALL_DIR)/*_patches_update.sql; do \
			echo "Applying $$f..."; \
			$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh install "$$(basename $$f)" || \
				echo "Warning: Failed to apply $$f (continuing)"; \
		done; \
	else \
		echo "Warning: No patch bundles found. Run 'make bundle_db' first."; \
	fi

fix_db:
	@echo "Applying SQL fixes..."
	@if ls $(SQL_INSTALL_DIR)/*_fixes.sql >/dev/null 2>&$(EXTRACTORS); then \
		for f in $(SQL_INSTALL_DIR)/*_fixes.sql; do \
			echo "Applying $$f..."; \
			$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh install "$$(basename $$f)" || \
				echo "Warning: Failed to apply $$f (continuing)"; \
		done; \
	else \
		echo "Warning: No fix bundles found. Run 'make bundle_db' first."; \
	fi

add_custom_db:
	@echo "Applying custom SQL..."
	@if ls $(SQL_INSTALL_DIR)/*_custom.sql >/dev/null 2>&$(EXTRACTORS); then \
		for f in $(SQL_INSTALL_DIR)/*_custom.sql; do \
			echo "Applying $$f..."; \
			$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh install "$$(basename $$f)" || \
				echo "Warning: Failed to apply $$f (continuing)"; \
		done; \
	else \
		echo "Warning: No custom bundles found. Run 'make bundle_db' first."; \
	fi

finalize_db:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh templates auth_update_template.sql

setup_db:
	@if [ "$(EXTERNAL_DB)" = "false" ]; then \
		$(DOCKER_COMPOSE) up -d db; \
		echo "Waiting 11 seconds for MySQL on $(DB_HOST) to start..."; \
		sleep 11; \
	fi

	@echo "Initializing databases..."
	$(MAKE) init_db
	@echo "Bundling SQL files..."
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/build_sql_bundles.sh
	@echo "Installing all SQL files..."
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/install_all_sql.sh
	@echo "Finalizing auth DB..."
	$(MAKE) finalize_db
	@echo "Database setup complete."

backup_db:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/backup_db.sh

restore_db:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/restore_db.sh

bundle_db:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/build_sql_bundles.sh


DIR ?= misc
FILE ?=
DB ?=

apply_sql:
	@if [ -n "$(FILE)" ]; then \
		$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh "$(DIR)" "$(FILE)" "$(DB)"; \
	else \
		$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh "$(DIR)" "" "$(DB)"; \
	fi
	
start:
	@echo "Starting services (DB: $(DB_MODE))"
	@if [ "$(EXTERNAL_DB)" = "false" ]; then \
		$(DOCKER_COMPOSE) up -d db authserver worldserver; \
	else \
		$(DOCKER_COMPOSE) up -d authserver worldserver; \
	fi

stop:
	@echo "Stopping services (DB: $(DB_MODE))"
	@if [ "$(EXTERNAL_DB)" = "false" ]; then \
		$(DOCKER_COMPOSE) stop db authserver worldserver; \
	else \
		$(DOCKER_COMPOSE) stop authserver worldserver; \
	fi

restart:
	@echo "Restarting services (DB: $(DB_MODE))"
	@if [ "$(EXTERNAL_DB)" = "false" ]; then \
		$(DOCKER_COMPOSE) restart db authserver worldserver; \
	else \
		$(DOCKER_COMPOSE) restart authserver worldserver; \
	fi

logs:
	@echo "Tailing logs (DB: $(DB_MODE))"
	@if [ "$(EXTERNAL_DB)" = "false" ]; then \
		$(DOCKER_COMPOSE) logs -f db authserver worldserver; \
	else \
		$(DOCKER_COMPOSE) logs -f authserver worldserver; \
	fi

down:
	@echo "Removing services (DB: $(DB_MODE))"
	@if [ "$(EXTERNAL_DB)" = "false" ]; then \
		$(DOCKER_COMPOSE) down db authserver worldserver; \
	else \
		$(DOCKER_COMPOSE) down authserver worldserver; \
	fi

uninstall:
	@echo "Removing all containers, volumes, and images..."
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands/exec_sql.sh templates uninstall_db_template.sql
	$(DOCKER_COMPOSE) down -v --rmi all --remove-orphans
	docker system prune -af

# --- Utilities ---
shell:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/bash

clean:
	docker image prune -f

telnet:
	@echo "Connecting to RA console at $(TELNET_HOST):$(TELNET_PORT)..."
	@telnet $(TELNET_HOST) $(TELNET_PORT)

configure_client:
	@sh misc/configure_client.sh '$(WOW_PATH)' '$(WOW_LOCALE)' '$(REALM_ADDRESS)'

apply_custom_config:
	$(DOCKER_COMPOSE) run --rm $(UTILITY) /bin/commands$(INSTALL_PREFIX) apply_custom_config.sh $(FILE)

install: fetch_source build compile extract_data setup_db configure start
	@echo "Installation complete. All services are running."

# --- Dependency Check ---
check:
	@echo "Checking required dependencies..."
	@if ! command -v docker >/dev/null 2>&$(EXTRACTORS); then \
		echo "Error: docker is not installed."; exit $(EXTRACTORS); \
	fi
	@if ! docker compose version >/dev/null 2>&$(EXTRACTORS); then \
		echo "Error: docker compose is missing."; exit $(EXTRACTORS); \
	fi
	@if ! command -v git >/dev/null 2>&$(EXTRACTORS); then \
		echo "Error: git is not installed."; exit $(EXTRACTORS); \
	fi
	@if ! command -v telnet >/dev/null 2>&$(EXTRACTORS); then \
		echo "Error: telnet is not installed."; exit $(EXTRACTORS); \
	fi
	@echo "All dependencies are present."

fetch_source:
	@if [ ! -d src/pandaria_5.4.8 ]; then \
		echo "Cloning $(PROJECT_NAME) source..."; \
		mkdir -p src; \
		git clone $(REPO_URL) src/pandaria_5.4.8; \
	else \
		echo "Updating $(PROJECT_NAME) source..."; \
		cd src/pandaria_5.4.8; \
		git pull --rebase; \
	fi