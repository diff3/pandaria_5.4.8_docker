#!/bin/sh
set -e

# Load environment variables if available
[ -f "/app/.env" ] && . /app/.env

SQL_DIR="/app/sql"

# List of SQL files to normalize (space-separated, no arrays)
FILES="$SQL_DIR/2024_08_01_world.sql \
$SQL_DIR/auth_04_03_2023.sql \
$SQL_DIR/characters_29_12_2024.sql \
$SQL_DIR/world_04_03_2023.sql"

echo "Normalizing database names in SQL files..."

for file in $FILES; do
  if [ -f "$file" ]; then
    echo "Patching $file..."
    sed -i -E "s/^(CREATE DATABASE .*|USE) *\`auth\`/\1 \`$AUTH_DB\`/g" "$file"
    sed -i -E "s/^(CREATE DATABASE .*|USE) *\`characters\`/\1 \`$CHARACTER_DB\`/g" "$file"
    sed -i -E "s/^(CREATE DATABASE .*|USE) *\`world\`/\1 \`$WORLD_DB\`/g" "$file"
  else
    echo "Warning: $file not found, skipping."
  fi
done

echo "Normalization complete. Files patched in-place."