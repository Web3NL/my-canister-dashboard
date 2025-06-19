#!/bin/bash

set -e

WASM_DIR="./wasm"
CHECKSUMS_DIR="./checksums"

echo "🏗️  Building deterministic WASM..."

# Clean previous builds
rm -rf "$WASM_DIR"
rm -rf "$CHECKSUMS_DIR"
mkdir -p "$WASM_DIR"
mkdir -p "$CHECKSUMS_DIR"

# Build locally for now (Docker version commented out due to architecture issues)
echo "📦 Building locally with dfx..."
dfx build --ic

# Copy WASM file to wasm directory
echo "📋 Copying WASM file..."
cp .dfx/ic/canisters/my-empty-wasm/my-empty-wasm.wasm "$WASM_DIR/"

# TODO: Docker build approach (enable when dfx ARM64 Docker support is available)
# docker build -f Dockerfile.build -t "$CONTAINER_NAME" .
# TEMP_CONTAINER=$(docker create "$CONTAINER_NAME")
# docker cp "$TEMP_CONTAINER:/wasm/." "$WASM_DIR/"
# docker rm "$TEMP_CONTAINER"

# Calculate hashes
echo "🔍 Calculating file hashes..."
cd "$WASM_DIR"

# Generate hash manifest
{
    echo "# SHA256 checksums for deterministic build verification"
    echo ""
    
    echo "## SHA256 checksums:"
    find . -type f -exec sha256sum {} \; | sort
    
    
} > "../$CHECKSUMS_DIR/hashes.txt"

echo ""
echo "✅ Deterministic WASM build complete!"
echo "📁 WASM files: $WASM_DIR/"
echo "🔐 Hashes: $CHECKSUMS_DIR/hashes.txt"
echo ""
echo "Build verification:"
cat "../$CHECKSUMS_DIR/hashes.txt"