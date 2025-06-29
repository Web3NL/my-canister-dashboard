#!/bin/bash

set -e

ASSETS_DIR="../assets"
CONTAINER_NAME="my-canister-dashboard-unified-builder"

echo "🏗️  Building deterministic frontend and WASM..."

# Clean previous builds
rm -rf "$ASSETS_DIR"
mkdir -p "$ASSETS_DIR"

# Build using Docker for deterministic builds
echo "📦 Building unified Docker image..."
cd .. && docker build --platform linux/amd64 -f my-canister-dashboard-rs/Dockerfile.build -t "$CONTAINER_NAME" . && cd my-canister-dashboard-rs

# Extract all assets from Docker container
echo "📋 Extracting assets from container..."
TEMP_CONTAINER=$(docker create "$CONTAINER_NAME")
docker cp "$TEMP_CONTAINER:/app/assets/." "$ASSETS_DIR/"
docker rm "$TEMP_CONTAINER"

# Generate unified hash manifest
echo "🔍 Calculating file hashes..."
cd "$ASSETS_DIR"


# Generate comprehensive hash manifest
{
    echo "## Frontend assets:"
    if [ -d "frontend" ]; then
        find frontend -type f -exec sha256sum {} \; | sort | sed 's/$/ sha256/'
    fi
    
    echo ""
    echo "## WASM assets:"
    if [ -d "wasm" ]; then
        find wasm -type f -exec sha256sum {} \; | sort | sed 's/$/ sha256/'
    fi
} > "hashes.txt"

cd ..

echo ""
echo "✅ Deterministic unified build complete!"
echo "📁 Assets: $ASSETS_DIR/"
echo "   ├── frontend/ (built frontend assets)"
echo "   ├── wasm/ (compiled WASM files)"
echo "   └── hashes.txt (SHA256 checksums)"
echo ""
echo "Build verification:"
cat "$ASSETS_DIR/hashes.txt"