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

# Detect CPU generation
CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo)

# Default flags
CXX_FLAGS="-pthread -O2"

# Disable march=native on older CPUs (Ivy Bridge and older)
if echo "$CPU_MODEL" | grep -Eq "i[357]-[23]"; then
    echo "Old CPU detected ($CPU_MODEL). Disabling -march=native and lowering optimization..."
    CXX_FLAGS="-pthread -O1"
else
    CXX_FLAGS="$CXX_FLAGS -march=native"
fi

# Export flags for cmake
export CMAKE_CXX_FLAGS="$CXX_FLAGS"

echo "Using C++ flags: $CXX_FLAGS"

# Run CMake configuration
cmake .. \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DCMAKE_C_COMPILER="$CMAKE_C_COMPILER" \
  -DCMAKE_CXX_COMPILER="$CMAKE_CXX_COMPILER" \
  -DSCRIPTS="$SCRIPTS" \
  -DWITH_WARNINGS="$WARNINGS" \
  -DTOOLS="$EXTRACTORS" \
  -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
  -DCMAKE_DISABLE_PRECOMPILE_HEADERS="$CMAKE_DISABLE_PCH" \
  -DACE_INCLUDE_DIR=/usr/include \
  -DACE_LIBRARY=/usr/lib/x86_64-linux-gnu/libACE.so

# Clean previous build
make clean

# Build and install if enabled
if [ "${MAKE_INSTALL:-1}" -eq 1 ]; then
    echo "Running make install..."

    # Determine number of cores to use
    TOTAL_CORES=$(nproc)
    if [ -z "${BUILD_CORES}" ] || [ "${BUILD_CORES}" -eq 0 ]; then
        CORES="$TOTAL_CORES"
    else
        CORES="${BUILD_CORES}"
    fi

    echo "Using $CORES cores for build (system has $TOTAL_CORES cores)"
    make -j"$CORES" install
fi

echo "=== Compile complete ==="