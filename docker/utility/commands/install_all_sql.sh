#!/bin/sh
set -e

# Expect PROJECT_NAME and SQL_INSTALL_DIR from container environment

# All SQL files to be processed (can be overridden by env var if needed)
FILES="
auth_base.sql
characters_base.sql
world_base.sql
auth_patches_update.sql
auth_fixes.sql
characters_patches_update.sql
characters_fixes.sql
world_update.sql
world_patches_update.sql
world_fixes.sql
auth_custom.sql
characters_custom.sql
world_custom.sql
"

echo "=== Installing all SQL files in order for $PROJECT_NAME ==="

for FILE in $FILES; do
    FULL_PATH="$SQL_INSTALL_DIR/$FILE"

    if [ ! -f "$FULL_PATH" ]; then
        echo "Warning: $FILE not found in $SQL_INSTALL_DIR, skipping."
        continue
    fi

    echo "Installing $FILE..."
    if ! /bin/commands/exec_sql.sh install "$FILE"; then
        echo "Error: Failed to execute $FILE (stopping)."
        exit 1
    fi
done

echo "=== All SQL installation complete ==="
