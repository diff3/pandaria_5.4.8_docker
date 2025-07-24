#!/bin/sh

echo "=== Compiling ==="

export LDFLAGS="-Wl,--copy-dt-needed-entries"

# Escape helper for sed replacements
escape() {
  local tmp
  tmp=$(echo "$1" | sed 's/[^a-zA-Z0-9\s:]/\\\&/g')
  echo "$tmp"
}

# Ensure runtime directories exist
mkdir -p "$INSTALL_PREFIX/logs" "$INSTALL_PREFIX/etc" "$INSTALL_PREFIX/bin" "$INSTALL_PREFIX/sql" "$INSTALL_PREFIX/data"
mkdir -p "$SOURCE_PREFIX/build"

cd "$SOURCE_PREFIX/build" || exit 1

# Run CMake configuration
cmake .. \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DCMAKE_C_COMPILER="$CMAKE_C_COMPILER" \
  -DCMAKE_CXX_COMPILER="$CMAKE_CXX_COMPILER" \
  -DSCRIPTS="$SCRIPTS" \
  -DWITH_WARNINGS="$WARNINGS" \
  -DTOOLS="$EXTRACTORS" \
  -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
  -DACE_INCLUDE_DIR=/usr/include \
  -DACE_LIBRARY=/usr/lib/x86_64-linux-gnu/libACE.so \

# Clean previous build
make clean

# Build and install if enabled
if [ "${MAKE_INSTALL:-1}" -eq 1 ]; then
    echo "Running make install..."

    # Determine number of cores to use
    TOTAL_CORES=$(nproc)
    if [ "${BUILD_CORES:-0}" -eq 0 ]; then
        CORES="$TOTAL_CORES"
    elif [ "${BUILD_CORES}" -lt 0 ]; then
        CORES=$((TOTAL_CORES + BUILD_CORES))
        [ "$CORES" -lt 1 ] && CORES=1  # Ensure at least 1 core
    else
        CORES="${BUILD_CORES}"
    fi

    echo "Using $CORES cores for build (system has $TOTAL_CORES cores)"
    make -j"$CORES" install
fi

echo "=== Compile complete ==="