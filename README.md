# Pandaria 5.4.8 Dockerized Server

## Introduction

This project is primarily intended **as a learning tool for Docker and containerized server setups**.  
It is **not designed to provide a fully managed, production-grade game server**.  
The setup demonstrates how to containerize and run Pandaria 5.4.8 using Docker, including automated builds, databases, and configuration management.


The goal of this project is to provide an easy way to build, configure, and run a Pandaria 5.4.8 server for private exploration and learning purposes only.

It is designed for:
	•	Running a local realm for personal use or a small group of friends.
	•	Experimenting with custom content, SQL tweaks, or server configurations.
	•	Quickly setting up and testing Pandaria 5.4.8 without manual dependency management.

This project is not intended for public or commercial server hosting.


### Key Features
- Automated **compilation and database setup** with `make`.
- Optional **internal MariaDB** or use of an **external database**.
- Built-in **tools for client configuration**, backups, and applying custom SQL or config changes.
- Fully modular: each service (authserver, worldserver, database, phpMyAdmin, utility) runs in its own container.
- Easily extensible with **custom SQL scripts** (`/app/custom_sql`) and **config overrides** (`/app/custom_conf`).

This setup is designed for **Linux hosts**, using Docker and Docker Compose.  
Windows and macOS support is possible but may require additional adjustments (especially for MariaDB and file paths).


## Important Notes

### Patching the MoP Client

Before running the server, your World of Warcraft: Mists of Pandaria client must be patched to work with the Pandaria 5.4.8 server.  
Follow the official instructions provided by SkyFire or the Pandaria 5.4.8 project for your client version.  
Without patching, the client may fail to connect or behave unexpectedly.  
For guidance, check the SkyFire project documentation or the Pandaria 5.4.8 repository for patching tools and instructions.



## Quick Installation Guide (Linux)

### 1. Install Prerequisites
Ensure the following are installed:
- Docker  
- Docker Compose  
- Git
- telnet

Use your Linux distribution’s package manager (e.g., `apt`, `dnf`, `pacman`) to install these manually.


---

### 2. Prepare Environment Configuration
Copy the example `.env` file:
```bash
cp env.dist .env
```

Then edit .env and update:
	•	REALM_ADDRESS (your server IP)
	•	WOW_PATH (path to your MoP client)
	•	Database settings (set EXTERNAL_DB=true if using your own database, otherwise internal DB is used)


### 3. Install and Run the Server

```bash
make install
````

This command will:
  1.  Fetch or update source code.
	2.	Build all required Docker containers (utility, authserver, worldserver, database if internal).
	3.	Compile the Pandaria 5.4.8 server.
	4.	Set up and configure the databases.
	5.	Generate configuration files for worldserver.conf and authserver.conf.
	6.	Extract all required data (maps, DBC, VMaps, and MMaps) into /app/data.
	7.	Start all services automatically.

### 4. Configure the WoW Client

```bash
make configure_client
````

This will automatically update:
	•	realmlist.wtf
	•	Config.wtf

5. Log In and Play
```bash
Username: admin
Password: admin
```

### 6. Creating Additional Accounts

You can create new player accounts using the built-in Remote Administration (RA) console via Telnet:

```bash
make telnet
```

This connects to the RA console using the REALM_ADDRESS and RA_PORT defined in your .env.
Default admin credentials


```bash
account create <username> <password>
account set gmlevel <username> 3 -1
```

GmLevels
	•	1 = Normal player (default access)
	•	3 = Highest GM privileges



# Detailed Installation Guide for Pandaria 5.4.8 Docker

This guide explains **how to set up, build, and run the Pandaria 5.4.8 private server** using the provided Docker setup.  
It breaks down the `Makefile` commands and shows their **manual Docker equivalents** for users who prefer to run everything step by step.

---

## 1. Prerequisites

- **Linux-based system** (tested on Debian 11, Arch, Manjaro)  
- **Docker** and **Docker Compose** installed  
- A copy of the **Mists of Pandaria 5.4.8 client** (patched as per [SkyFire instructions](https://github.com/alexkulya/pandaria_5.4.8))  
- Rename and configure `.env`:
  ```bash
  cp env.dist .env
  nano .env
  ```
  Update:
  - `REALM_ADDRESS` (your server IP)
  - `WOW_PATH` (path to your MoP client)
  - Database settings (`EXTERNAL_DB`, `DB_HOST`, etc.)

---

## 2. Quick Install (Automatic)

The simplest way to set everything up is:
```bash
make install
```

This will:
1. **Clone** all necessary git repos.
2. **Build** all necessary containers (utility, authserver, worldserver, optional DB).
3. **Compile** the Pandaria core.
4. **Extract** maps, vmaps, and mmaps if needed.
5. **Set up databases** (initialize, populate, update, finalize).
6. **Generate default configuration files** (`worldserver.conf`, `authserver.conf`).
7. **Start all services** (authserver, worldserver, optional DB).

After the process completes, you can check logs:
```bash
make logs
```

---

## 3. Step-by-Step Installation (Manual Mode)

If you don’t want to use `make install`, here’s how to do it manually:

### Step 1 – Clone the source code
```bash
cd src
git clone https://github.com/alexkulya/pandaria_5.4.8.git
```

### Step 2 – Build the Utility Container
```bash
docker compose build utility
```

### Step 3 – Compile the Pandaria Core
```bash
docker compose run --rm utility compile
```

### Step 4 – Extract Game Data (DBC, Maps, VMaps, MMaps)
```bash
docker compose run --rm utility extract_data
```

### Step 5 – Set Up the Database
Initialize and populate the MariaDB/MySQL databases:
```bash
docker compose run --rm utility init_db
docker compose run --rm utility populate_db
docker compose run --rm utility update_db
docker compose run --rm utility finalize_db
```

### Step 6 – Generate Config Files
```bash
docker compose run --rm utility configure
```

### Step 7 – Start the Server
```bash
docker compose up -d
```

### Step 8 – View Logs
```bash
docker compose logs -f
```

---

## 4. Useful `make` Commands (Shortcuts)

- `make start` – Start all containers (authserver, worldserver, optional DB).  
- `make stop` – Stop all containers.  
- `make restart` – Restart all containers.  
- `make logs` – Follow logs for all containers.  
- `make shell` – Enter the utility container for debugging.  
- `make uninstall` – Remove containers, volumes, DB, and images.

---

## 5. Setting Up the WoW Client

To automatically configure your WoW client’s `realmlist.wtf` and `Config.wtf`:
```bash
make configure_client
```

Manually (without `make`):
```bash
sh misc/configure_client.sh "/path/to/World of Warcraft MoP" "enGB" "192.168.1.100"
```

---

## 6. Creating Accounts via Telnet (RA Console)

After the server is running:
```bash
make telnet
```

Default RA credentials (unless changed in `.env`):
```
Username: admin
Password: admin
```

Create a new account:
```
account create test test123
account set gmlevel test 3 -1
```

- `1` = Normal player  
- `3` = Highest GM (full access)

---

## 7. Optional Customization

- Place **custom configuration files** in `/app/custom_conf/`  
  and apply them with:
  ```bash
  make apply_custom_config
  ```
  Or a single file:
  ```bash
  make apply_custom_config FILE=world.conf
  ```

- Place **SQL fixes or custom scripts** in `/app/custom_sql/fixes` or `/app/custom_sql/custom`.  
  These are automatically applied during database updates.

---

With these steps, you can **run your own Pandaria 5.4.8 server** either with the automated `make` workflow or by executing all Docker commands manually.



## Directory Overview

This project uses several directories to organize source code, configuration, and runtime data.  
Below is an overview of each important directory and its purpose. Once connected, you can create accounts with:





| Directory                      | Purpose                                                                                 |
|--------------------------------|-----------------------------------------------------------------------------------------|
| **/app/**                      | Main runtime directory for the Pandaria server. Contains configuration, logs, SQL, and runtime data. |
| **/app/custom_conf/**          | Stores custom configuration files for `authserver.conf` and `worldserver.conf`. These files can be applied using `make apply_custom_config` or manually. |
| **/app/custom_sql/**           | Holds custom SQL scripts organized into subfolders:                                   |
|                                | &nbsp;&nbsp;• **fixes/** – SQL scripts applied **after the world database dump** but before incremental updates. Typically used to fix tables or schema issues. |
|                                | &nbsp;&nbsp;• **custom/** – SQL scripts applied **after all updates are complete**, for adding mounts, free shop items, or other custom features. |
|                                | &nbsp;&nbsp;• **misc/** – SQL scripts stored here will **not be executed automatically** (for manual testing or reference). |
| **/app/sql/**                  | Stores official base SQL dumps (auth, characters, world) and the main world database ZIP download. Should not be edited manually. |
| **/app/logs/**                 | Contains logs from the `authserver` and `worldserver`. Useful for debugging. |
| **/app/data/**                 | Holds game data extracted from the WoW client (`dbc`, `maps`, `vmaps`, `mmaps`). Required for the server to run. |
| **/backup/**                   | Location for automated database backups. Used by `make backup_db` and `make restore_db`. |
| **/src/**                      | Contains the Pandaria source code for compilation. Not tracked in Git (except for `.keep` files). |
| **/docker/**                   | Contains Dockerfiles and related scripts for building containers. |
| **/misc/**                     | Miscellaneous utility scripts (e.g., `configure_client.sh` for updating the WoW client realmlist). |

### Notes:
- Files like `.keep` are used to preserve empty directories in Git but have no functional purpose.
- Most directories (`/app/sql`, `/app/data`, `/src`, `/backup`) are ignored by Git except for `.keep` markers and specific custom folders.
- SQL scripts in `custom_sql/fixes` and `custom_sql/custom` are run automatically during `make setup_db`.  
  Scripts in `custom_sql/misc` **must be run manually** if needed.

  ### Disclaimer

This project is **intended solely for private exploration and learning purposes**.  
It is not designed or supported for public hosting, commercial use, or as a production-grade server.  
The goal is to help users learn about Docker, experiment with Pandaria 5.4.8, and explore custom server configurations in a controlled, private environment.