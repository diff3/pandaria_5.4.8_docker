#!/bin/sh
set -e

# Load environment variables if available
[ -f "/app/.env" ] && . /app/.env

SQL_DIR="/app/sql/install"
TMP_DIR="$SQL_DIR/tmp"

WORLD_ZIP="$WORLD_DB_ZIP"
WORLD_URL="$WORLD_DB_URL"

AUTH_BUNDLE="$SQL_DIR/auth_base.sql"
CHAR_BUNDLE="$SQL_DIR/characters_base.sql"
WORLD_BUNDLE="$SQL_DIR/world_base.sql"
WORLD_UPDATE="$SQL_DIR/world_update.sql"

AUTH_PATCHES="$SQL_DIR/auth_patches_update.sql"
CHAR_PATCHES="$SQL_DIR/characters_patches_update.sql"
WORLD_PATCHES="$SQL_DIR/world_patches_update.sql"

# --- Prepare directories ---
mkdir -p "$SQL_DIR" "$TMP_DIR"

echo "=== Building bundled SQL files ==="

# --- Extract base SQL from zips ---
echo "Unzipping base databases..."
unzip -o "$SOURCE_PREFIX/sql/base/auth_04_03_2023.zip" -d "$TMP_DIR"
unzip -o "$SOURCE_PREFIX/sql/base/characters_29_12_2024.zip" -d "$TMP_DIR"
unzip -o "$SOURCE_PREFIX/sql/base/world_04_03_2023.zip" -d "$TMP_DIR"

# Move/rename base SQL to consistent names
mv -f "$TMP_DIR/$AUTH_SQL" "$AUTH_BUNDLE"
mv -f "$TMP_DIR/$CHARACTER_SQL" "$CHAR_BUNDLE"
mv -f "$TMP_DIR/$WORLD_SQL" "$WORLD_BUNDLE"

# --- Download & prepare world update ---
if [ ! -f "$WORLD_ZIP" ]; then
    echo "Downloading latest world dump..."
    wget --progress=bar:force:noscroll "$WORLD_URL" -O "$WORLD_ZIP"
fi

echo "Extracting latest world update..."
unzip -o "$WORLD_ZIP" -d "$TMP_DIR"

# Move world update SQL from tmp to install dir
WORLD_UPDATE_SRC="$TMP_DIR/$(basename "$WORLD_SQL_UPDATE")"
if [ -f "$WORLD_UPDATE_SRC" ]; then
    mv -f "$WORLD_UPDATE_SRC" "$WORLD_UPDATE"
else
    echo "Error: Expected world update file $WORLD_UPDATE_SRC not found."
    exit 1
fi

# --- Merge incremental patches into single files ---
merge_patches() {
    local src_dir="$1"
    local target="$2"

    if [ ! -d "$src_dir" ]; then
        echo "No patches in $src_dir, skipping."
        return
    fi

    echo "Merging patches from $src_dir into $target..."
    cat $(find "$src_dir" -type f -name '*.sql' | sort) > "$target"
}

merge_patches "$SOURCE_PREFIX/sql/updates/auth" "$AUTH_PATCHES"
merge_patches "$SOURCE_PREFIX/sql/updates/characters" "$CHAR_PATCHES"
merge_patches "$SOURCE_PREFIX/sql/updates/world" "$WORLD_PATCHES"

# --- Normalize DB names in all SQL files ---
echo "Normalizing database names..."
for file in "$SQL_DIR"/*.sql; do
    [ -f "$file" ] || continue
    echo "Patching $file..."
    sed -i -E "s/(CREATE DATABASE.*|USE) *\`auth\`/\1 \`$AUTH_DB\`/Ig" "$file"
    sed -i -E "s/(CREATE DATABASE.*|USE) *\`characters\`/\1 \`$CHARACTER_DB\`/Ig" "$file"
    sed -i -E "s/(CREATE DATABASE.*|USE) *\`world\`/\1 \`$WORLD_DB\`/Ig" "$file"
done

# --- Cleanup ---
rm -rf "$TMP_DIR"

echo "=== All bundled SQL files are ready in $SQL_DIR ==="
echo "Generated:"
ls -1 "$SQL_DIR"/*.sql || echo "(No files generated)"