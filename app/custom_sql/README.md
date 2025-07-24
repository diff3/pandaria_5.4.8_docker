# Custom SQL Directories

This folder allows you to organize **optional and custom SQL scripts** for the Pandaria 5.4.8 server.  
It is divided into three subdirectories, each with a specific purpose and execution timing.

## Directory Overview

### 1. `fixes/`
- **Purpose:** Used for database fixes that must run **after the world dump** but **before incremental updates**.
- **When executed:** Automatically during `make update_db`, right after the main world database is imported.
- **Usage:** Place SQL scripts here to recreate missing tables, adjust schema issues, or repair broken imports.
- **Naming convention:**  
  - `world_*.sql` → targets the **World** database.  
  - `auth_*.sql` → targets the **Auth** database.  
  - `characters_*.sql` → targets the **Characters** database.

---

### 2. `custom/`
- **Purpose:** For **custom gameplay changes** that should apply **after all updates and fixes**.
- **When executed:** Runs **last** during `make update_db`.
- **Usage:** Use for custom features, like:
  - Adding free mounts or custom vendors.
  - Adjusting shop prices or currency.
  - Adding special NPCs or events.
- **Naming convention:** Same as `fixes/`.

---

### 3. `misc/`
- **Purpose:** Storage for **SQL scripts you do not want executed automatically**.
- **When executed:** **Never automatically.**  
  These files are for reference, manual execution, or testing.
- **Usage:** Keep drafts, old fixes, or optional scripts here.

---

## Execution Order

During `make update_db`, the directories run in this sequence:

1. World dump import  
2. `fixes/` (schema or table fixes)  
3. Incremental updates (official update scripts)  
4. `custom/` (optional gameplay and balance changes)  

Scripts in each directory run **alphabetically**.

---

## Running Scripts Manually

You can trigger them independently:

```bash
# Run all fixes only
docker compose run --rm utility /bin/commands/run_sql_fixes.sh

# Run all custom scripts only
docker compose run --rm utility /bin/commands/run_custom_sql.sh

docker compose run --rm utility mysql \
  -h $DB_HOST -P $DB_PORT -u $SERVER_DB_USER -p$SERVER_DB_PASSWORD $WORLD_DB < path/to/script.sql
```

## Recommendations
	•	Always back up your databases with make backup_db before testing custom scripts.
	•	Use misc/ for any scripts you want to keep but not run automatically.
	•	Follow the naming convention (world_, auth_, characters_) so scripts target the correct database.