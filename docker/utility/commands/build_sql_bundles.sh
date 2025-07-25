#!/bin/sh
set -e

echo "=== Building SQL bundles (base, update, patches, fixes, custom) ==="

INSTALL_DIR="/app/sql/install"
UPDATES_DIR="$SOURCE_PREFIX/sql/updates"
BASE_DIR="$SOURCE_PREFIX/sql/base"
FIXES_DIR="/app/sql/fixes"
CUSTOM_DIR="/app/sql/custom"

# Se till att katalogen finns och töm den
mkdir -p "$INSTALL_DIR"
rm -f "$INSTALL_DIR"/*.sql

# --- 1. Extrahera base-databaser ---
echo "Extracting base databases..."
unzip -o "$BASE_DIR/auth_*.zip" -d "$INSTALL_DIR"
mv "$INSTALL_DIR/$AUTH_SQL" "$INSTALL_DIR/auth_base.sql"

unzip -o "$BASE_DIR/characters_*.zip" -d "$INSTALL_DIR"
mv "$INSTALL_DIR/$CHARACTER_SQL" "$INSTALL_DIR/characters_base.sql"

unzip -o "$BASE_DIR/world_*.zip" -d "$INSTALL_DIR"
mv "$INSTALL_DIR/$WORLD_SQL" "$INSTALL_DIR/world_base.sql"

# --- 2. Hämta world-update ---
if [ ! -f "$WORLD_DB_ZIP" ]; then
    echo "Downloading latest world database..."
    wget --progress=bar:force:noscroll "$WORLD_DB_URL" -O "$WORLD_DB_ZIP"
fi

echo "Extracting world update..."
unzip -o "$WORLD_DB_ZIP" -d "$INSTALL_DIR"
mv "$WORLD_SQL_UPDATE" "$INSTALL_DIR/world_update.sql"

# --- 3. Bygg patch-filer (en per DB) ---
build_patch_file() {
    local db_prefix="$1"   # auth, characters, world
    local output="$INSTALL_DIR/${db_prefix}_patches_update.sql"

    echo "-- Combined patches for $db_prefix" > "$output"

    if [ -d "$UPDATES_DIR/$db_prefix" ]; then
        for patch in $(ls "$UPDATES_DIR/$db_prefix"/*.sql 2>/dev/null | sort); do
            echo "Adding patch: $(basename "$patch")"
            cat "$patch" >> "$output"
            echo "" >> "$output"
        done
    else
        echo "-- No patches for $db_prefix" >> "$output"
    fi
}

build_patch_file "auth"
build_patch_file "characters"
build_patch_file "world"

# --- 4. Bundla fixes och custom (en per DB) ---
bundle_extra_sql() {
    local src_dir="$1"   # katalog (fixes eller custom)
    local type="$2"      # "fixes" eller "custom"

    for db_prefix in auth characters world; do
        local output="$INSTALL_DIR/${db_prefix}_${type}.sql"
        local files=$(ls "$src_dir/${db_prefix}_*.sql" 2>/dev/null | sort || true)

        if [ -z "$files" ]; then
            echo "No $type SQL files for $db_prefix, skipping."
            rm -f "$output" 2>/dev/null || true
            continue
        fi

        echo "Bundling $type SQL for $db_prefix into $(basename "$output")..."
        echo "-- Combined $type for $db_prefix" > "$output"
        for f in $files; do
            cat "$f" >> "$output"
            echo "" >> "$output"
        done
    done
}

bundle_extra_sql "$FIXES_DIR" "fixes"
bundle_extra_sql "$CUSTOM_DIR" "custom"

# --- 5. Normalisera alla SQL-filer (inklusive fixes/custom) ---
echo "Normalizing SQL files..."
/bin/commands/normalize_sql.sh

echo "=== SQL bundle build complete. Generated files: ==="
ls -1 "$INSTALL_DIR"/*.sql