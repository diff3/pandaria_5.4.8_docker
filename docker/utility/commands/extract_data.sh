#!/bin/sh
set -e

echo "=== Starting data extraction for $PROJECT_NAME ==="

# Cleanup temporary files
echo "--- Cleaning up temporary files ---"
rm -rf "$WOW_INTERNAL/Buildings" || true
rm -f "$WOW_INTERNAL/vmap4extractor" || true

# Creating directories if needed
BIN_DIR="$INSTALL_PREFIX/bin"
DATA_DIR="$INSTALL_PREFIX/data"
mkdir -p "$DATA_DIR"

# Extract basic game data (DBC, Camera, and Maps)
cd "$BIN_DIR"

if [ "$MAPS" = "ON" ]; then
    rm -rf "$DATA_DIR/dbc" || true

    echo "--- Extracting DBC, Camera, and Maps ---"
    ./mapextractor -i "$WOW_INTERNAL" -o "$DATA_DIR"

    echo "--- Fixing DBC filenames ---"
    if [ -d "$DATA_DIR/dbc" ]; then
        find "$DATA_DIR/dbc" -type f -name '*\\*' | while read -r file; do
            fixed_name=$(echo "$file" | tr -d '\\')
            if [ "$file" != "$fixed_name" ]; then
                mv "$file" "$fixed_name"
                echo "Renamed: $file -> $fixed_name"
            fi
        done
    fi
fi

# Extract and assemble VMAPS
if [ "$VMAPS" = "ON" ]; then
    echo "--- Extracting VMAPS ---"
    rm -rf "$DATA_DIR/vmaps" || true
    mkdir -p "$DATA_DIR/vmaps"
    cp "$BIN_DIR/vmap4extractor" "$WOW_INTERNAL/"
    cd "$WOW_INTERNAL"
    ./vmap4extractor -l -b "$DATA_DIR"

    echo "--- Assembling VMAPS ---"
    cd "$BIN_DIR"
    ./vmap4assembler "$WOW_INTERNAL/Buildings" "$DATA_DIR/vmaps"
fi

# Generate MMAPS
if [ "$MMAPS" = "ON" ]; then
    echo "--- Generating MMAPS ---"
    rm -rf "$DATA_DIR/mmaps" || true
    mkdir -p "$DATA_DIR/mmaps"
    cp "$BIN_DIR/mmaps_generator" "$DATA_DIR"
    cd "$DATA_DIR"
    ./mmaps_generator
fi

# Cleanup temporary files
echo "--- Cleaning up temporary files ---"
rm -rf "$WOW_INTERNAL/Buildings" || true
rm -rf "$BIN_DIR/Buildings" || true
rm -f "$WOW_INTERNAL/vmap4extractor" || true
rm -f "$DATA_DIR/mmaps_generator" || true

echo "=== Data extraction complete ==="
