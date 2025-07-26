#!/bin/sh
set -e



# --- Default variables (overridable via .env) ---
PROJECT_NAME="${PROJECT_NAME:-Pandaria}"
INSTALL_PREFIX="${INSTALL_PREFIX:-/app}"
SOURCE_PREFIX="${SOURCE_PREFIX:-/src/pandaria_5.4.8}"
BUILD_DIR="$SOURCE_PREFIX/build"

echo "=== Compiling Project $PROJECT_NAME ==="

# Compiler defaults (from .env or fallback)
CMAKE_C_COMPILER="${CMAKE_C_COMPILER:-/usr/bin/clang-14}"
CMAKE_CXX_COMPILER="${CMAKE_CXX_COMPILER:-/usr/bin/clang++-14}"
CMAKE_DISABLE_PCH="${CMAKE_DISABLE_PCH:-ON}" # Disable precompiled headers for stability
BUILD_CORES="${BUILD_CORES:-0}" # 0 = all cores

# Flags (can be overridden by CMAKE_CXX_FLAGS in .env)
if [ -z "$CMAKE_CXX_FLAGS" ]; then
    CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo || true)
    BASE_FLAGS="-pthread -O2"

    # Lower optimization for older CPUs (Ivy Bridge and older)
    if echo "$CPU_MODEL" | grep -Eq "i[357]-[23]"; then
        echo "Old CPU detected ($CPU_MODEL). Disabling -march=native and lowering optimization..."
        CMAKE_CXX_FLAGS="-pthread -O1"
    else
        CMAKE_CXX_FLAGS="$BASE_FLAGS -march=native"
    fi
fi

export LDFLAGS="-Wl,--copy-dt-needed-entries"
export CMAKE_CXX_FLAGS

echo "Using compiler: $CMAKE_CXX_COMPILER"
echo "C++ Flags: $CMAKE_CXX_FLAGS"
echo "Project: $PROJECT_NAME"

# --- Ensure runtime directories exist ---
mkdir -p "$INSTALL_PREFIX/logs" "$INSTALL_PREFIX/etc" "$INSTALL_PREFIX/bin" "$INSTALL_PREFIX/sql" "$INSTALL_PREFIX/data" "$INSTALL_PREFIX/lib"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# --- Run CMake ---
cmake .. \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DCMAKE_C_COMPILER="$CMAKE_C_COMPILER" \
  -DCMAKE_CXX_COMPILER="$CMAKE_CXX_COMPILER" \
  -DSCRIPTS="${SCRIPTS:-ON}" \
  -DWITH_WARNINGS="${WARNINGS:-OFF}" \
  -DTOOLS="${EXTRACTORS:-ON}" \
  -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
  -DCMAKE_DISABLE_PRECOMPILE_HEADERS="$CMAKE_DISABLE_PCH" \
  -DACE_INCLUDE_DIR="${ACE_INCLUDE_DIR:-/usr/include}" \
  -DACE_LIBRARY="${ACE_LIBRARY:-/usr/lib/x86_64-linux-gnu/libACE.so}"

# --- Clean old build ---
make clean

# --- Build & install ---
if [ "${MAKE_INSTALL:-1}" -eq 1 ]; then
    echo "Running make install..."
    TOTAL_CORES=$(nproc)
    if [ "$BUILD_CORES" -eq 0 ]; then
        CORES="$TOTAL_CORES"
    else
        CORES="$BUILD_CORES"
    fi

    echo "Using $CORES cores for build (System total: $TOTAL_CORES)"
    make -j"$CORES" install
fi

echo "=== Compile complete for $PROJECT_NAME ==="
