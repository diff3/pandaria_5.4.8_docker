# Pandaria 5.4.8 – Dockerized Server

## Overview

This project provides a **Docker-based setup** for Pandaria 5.4.8, intended as a **learning tool** for containerized game servers.  
It is not designed for public hosting or production use but offers a quick way to build, configure, and run Pandaria 5.4.8 locally.

---

## Purpose

With this project, you can:
- Quickly build and run a Pandaria 5.4.8 server without manual dependency management.
- Experiment with SQL tweaks, custom content, and server configurations.
- Learn Docker workflows for multi-service setups.

This is primarily for **personal use, testing, and education**, not for commercial or large-scale deployment.

---

## Key Features
- Automated **compilation and database setup** with `make`.
- Support for **internal MariaDB** or **external database connections**.
- Modular services: each component (authserver, worldserver, database, phpMyAdmin, utilities) runs in its own container.
- Tools for **client configuration**, backups, and applying custom SQL or configuration overrides.
- Customization via `/app/custom_sql` and `/app/custom_conf`.

This setup is tested on **Linux hosts** with Docker and Docker Compose.  
Windows and macOS are supported but may require manual tweaks, especially for MariaDB and file paths.

---

## Client Preparation

Before starting the server, your **World of Warcraft: Mists of Pandaria client (5.4.8)** must be patched to connect properly.  
Follow the instructions provided by the SkyFire or Pandaria 5.4.8 project for your client version.  
Without proper patching, the client may not connect or may behave unpredictably.

---

## Limitations

- Intended for **private, educational use only**.
- Not optimized for **public or production servers**.

---

## Quick Installation Guide (Linux)

### 1. Prerequisites
Ensure the following are installed:
- Docker  
- Docker Compose  
- Git  
- Telnet client  

Install them using your distribution’s package manager (e.g., `apt`, `dnf`, or `pacman`).

---

### 2. Environment Setup
Copy the example `.env` file and configure it:
```bash
cp env.dist .env
```

Edit .env to set:
	•	REALM_ADDRESS – your server IP or hostname
	•	WOW_PATH – path to your MoP 5.4.8 client
	•	Database settings – set EXTERNAL_DB=true if you want to use an existing database; otherwise, the internal MariaDB container will be used.


### 3. Install and Run the Server

```bash
make install
````

This command will:
	1.	Fetch or update the source code.
	2.	Build all Docker containers (utility, authserver, worldserver, database if internal).
	3.	Compile the Pandaria 5.4.8 server.
  4.	Extract maps, DBC, VMaps, and MMaps into /app/data.
	5.	Initialize and configure the database.
	6.	Generate worldserver.conf and authserver.conf.
	7.	Start all services automatically.

### 4. Configure the WoW Client

```bash
make configure_client
````

This will automatically update:
	•	realmlist.wtf
	•	Config.wtf

### 5. Log In and Play

Use the default administrator account (GM Level 3 – full privileges):
```bash
Username: admin
Password: admin
```

### 6. Creating Additional Accounts

Use the built-in Remote Administration (RA) console via Telnet, logged in as the **default admin account** (GM Level 3):

```bash
make telnet
```

This will connect to the RA console using REALM_ADDRESS and RA_PORT from your .env.
Log in with: admin pass: admion


```bash
account create <username> <password>
account set gmlevel <username> <gmlevel> <realmID>
```

GmLevels
	•	1 = Normal player (default access)
	•	3 = Highest GM privileges

RealmID
	•	The last argument is the realmID.
	•	By default, the primary realm uses ID 1.
	•	Use -1 to apply the same GM permission across all realms.

## Manual Setup (without make install)

If you prefer to run each step manually, you can use the underlying Docker Compose commands directly

```bash
# 1. Build the utility container (compiles SkyFire and provides tools)
docker compose build utility

# 2. Compile the Pandaria 5.4.8 core
docker compose run --rm utility compile

# 3. Extract maps, DBC, VMaps, and MMaps
docker compose run --rm utility extract_data

# 4. Initialize and populate the database
docker compose run --rm utility init_db
docker compose run --rm utility populate_db
docker compose run --rm utility update_db
docker compose run --rm utility finalize_db

# 5. Generate configuration files
docker compose run --rm utility configure

# 6. Start the servers (authserver, worldserver, and database if internal)
docker compose up -d

# 7. Follow the logs
docker compose logs -f
```



## Directory Overview

This project uses several directories to organize source code, configuration, and runtime data.  
Below is an overview of each important directory and its purpose. Once connected, you can create accounts with:


## Directory Overview

| Directory                          | Purpose                                                                 |
|------------------------------------|-------------------------------------------------------------------------|
| `app/bin`                          | Compiled binaries (e.g., `authserver`, `worldserver`, and data tools). |
| `app/custom_conf`                  | User-provided configuration overrides, merged after defaults.          |
| `app/data`                         | Extracted game data (maps, DBC, VMaps, MMaps) used by the servers.     |
| `app/etc`                          | Default configuration files for the servers (`authserver.conf`, etc.). |
| `app/lib`                          | Libraries required by the server binaries (if not system-installed).   |
| `app/logs`                         | Log files from `authserver`, `worldserver`, and other services.        |
| `app/sql/backup`                   | Database backups (full or partial exports).                            |
| `app/sql/custom`                   | Custom SQL scripts applied **after** all updates (for mounts, tweaks). |
| `app/sql/fixes`                    | Fix scripts run **after DB updates but before minor patches**.         |
| `app/sql/install`                  | Base database installation scripts for auth/world/characters DBs.      |
| `app/sql/misc`                     | SQL scripts not applied automatically (manual tweaks or experiments).  |
| `app/sql/templates`                | Template SQL files for custom database structures or test realms.      |
| `app/wow`                          | Local copy of the MoP 5.4.8 client (used for data extraction).         |
| `docker/authserver`                | Dockerfile and configs for building the `authserver` container.        |
| `docker/utility`                   | Dockerfile and build environment for compiling, tools, and data tasks. |
| `docker/worldserver`               | Dockerfile and configs for building the `worldserver` container.       |
| `misc`                             | Helper scripts (client configurators, tools, maintenance).             |
| `src`                              | Source code for the Pandaria 5.4.8 core and its dependencies.          |


## SQL Execution Order

During `make install` and database initialization, SQL scripts from `/app/sql` are executed in the following order:

1. **`install/`** – Base schema and data for the `auth`, `characters`, and `world` databases.  
2. **Official updates** – Incremental updates from the core repository.  
3. **`fixes/`** – Custom fixes applied **after official updates but before final adjustments** (e.g., bug fixes, structural corrections).  
4. **`custom/`** – Custom gameplay changes (mounts, vendors, rates) applied **last**, after all updates and fixes.  
5. **`misc/`** – Not run automatically. Use for manual tweaks or experiments:
6. **`backup/`** – Contains database dumps for rollback or migration, not executed automatically.
7. **`templates/`**  – Provides base structures or sample realms; not applied unless explicitly called.

This order ensures:
	•	The database is built from a clean state.
	•	Official updates are always applied first.
	•	Fixes and customizations never conflict with core updates.
	•	Experimental SQL stays separate until explicitly executed.


## Applying Custom SQL and Config Files

You can manually run SQL scripts or apply configuration overrides without re-running the full installation.  
**Note:** After applying SQL or configuration changes, you must restart `worldserver` (and `authserver` if configs were updated) for the changes to take effect.


### Running SQL Scripts

The `make apply_sql` target executes SQL files against the chosen database.  
Usage:
```bash
make apply_sql <directory> [FILE=<filename.sql>] [DB=<database>]
```

Parameters:
	•	<directory> – One of the SQL directories under /app/sql (misc, custom, fixes, etc.).
	•	FILE – (Optional) The SQL file to run. If omitted, all files in the directory will be applied.
	•	DB – (Optional) Target database (auth, characters, or world).
	•	If omitted, the system attempts to infer the target DB from the file name (e.g., auth_*.sql → auth DB).

```bash
# Apply a single SQL file to the inferred database
make apply_sql misc FILE=my_script.sql

# Apply a single file to a specific database
make apply_sql custom FILE=my_custom_world.sql DB=world

# Apply all SQL files in the fixes directory
make apply_sql fixes
```


### Applying Custom Config Overrides

```bash
make apply_custom_config [FILE=<filename.conf>]
```

Parameters:
	•	FILE – (Optional) Apply a single configuration file.
	•	If omitted, all files in /app/custom_conf will be applied.


```bash
# Apply all configuration overrides
make apply_custom_config

# Apply only a specific override
make apply_custom_config FILE=worldserver.conf
```

Reminder: After applying configuration overrides, restart worldserver (and authserver if affected) for the new settings to load.



### Notes:
- Files like `.keep` are used to preserve empty directories in Git but have no functional purpose.
- Most directories (`/app/sql`, `/app/data`, `/src`, `/backup`) are ignored by Git except for `.keep` markers and specific custom folders.
- SQL scripts in `custom_sql/fixes` and `custom_sql/custom` are run automatically during `make setup_db`.  
  Scripts in `custom_sql/misc` **must be run manually** if needed.

  ### Disclaimer

This project is **intended solely for private exploration and learning purposes**.  
It is not designed or supported for public hosting, commercial use, or as a production-grade server.  
The goal is to help users learn about Docker, experiment with Pandaria 5.4.8, and explore custom server configurations in a controlled, private environment.