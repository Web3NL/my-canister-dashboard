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

# Build using Docker for deterministic builds
CONTAINER_NAME="my-empty-wasm-builder"
echo "📦 Building with Docker using pinned dfx image..."
cd .. && docker build -f my-empty-wasm/Dockerfile.build -t "$CONTAINER_NAME" . && cd my-empty-wasm

# Extract WASM files from Docker container
echo "📋 Extracting WASM files from container..."
TEMP_CONTAINER=$(docker create "$CONTAINER_NAME")
docker cp "$TEMP_CONTAINER:/wasm/." "$WASM_DIR/"
docker rm "$TEMP_CONTAINER"

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