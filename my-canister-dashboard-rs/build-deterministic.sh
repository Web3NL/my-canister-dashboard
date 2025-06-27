#!/bin/bash

set -e

WASM_DIR="./wasm"

echo "🏗️  Building deterministic WASM..."

# Build using Docker for deterministic builds
CONTAINER_NAME="my-canister-dashboard-rs-builder"
cd .. && docker build --platform linux/amd64 -f my-canister-dashboard-rs/Dockerfile.build -t "$CONTAINER_NAME" . && cd my-canister-dashboard-rs

# Extract WASM files from Docker container
echo "📋 Extracting WASM files from container..."
TEMP_CONTAINER=$(docker create "$CONTAINER_NAME")
docker cp "$TEMP_CONTAINER:/app/my-canister-dashboard-rs/wasm/." "$WASM_DIR/"
docker rm "$TEMP_CONTAINER"

# Generate hash manifest in the wasm directory
cd "$WASM_DIR"
sha256sum *.wasm > "hashes.txt"
cd ..

echo ""
echo "✅ Deterministic WASM build complete!"
echo "📁 WASM files: $WASM_DIR/"
echo "🔐 Hashes: $WASM_DIR/hashes.txt"
echo ""
echo "Build verification:"
cat "$WASM_DIR/hashes.txt"