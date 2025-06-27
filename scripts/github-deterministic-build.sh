#!/bin/bash

set -e

echo "🏗️  GitHub Deterministic Build and Hash Verification"
echo "=================================================="

# Linting and formatting already done in CI lint-and-format job

# Temporary directories for GitHub build artifacts
TEMP_FRONTEND_DIR="/tmp/github-frontend-build"
TEMP_WASM_DIR="/tmp/github-wasm-build"
TEMP_CHECKSUMS_DIR="/tmp/github-checksums"

# Clean up function
cleanup() {
    echo "🧹 Cleaning up temporary directories..."
    rm -rf "$TEMP_FRONTEND_DIR" "$TEMP_WASM_DIR" "$TEMP_CHECKSUMS_DIR"
}
trap cleanup EXIT

# Create temporary directories
mkdir -p "$TEMP_FRONTEND_DIR" "$TEMP_WASM_DIR" "$TEMP_CHECKSUMS_DIR"

echo ""
echo "📦 Building Frontend Docker Image..."
echo "===================================="

# Build frontend Docker image
cd canister-dashboard-frontend
FRONTEND_CONTAINER_NAME="github-frontend-builder"
docker build --platform linux/amd64 -f Dockerfile.build -t "$FRONTEND_CONTAINER_NAME" .

# Extract frontend build artifacts
echo "📋 Extracting frontend build files..."
TEMP_CONTAINER=$(docker create "$FRONTEND_CONTAINER_NAME")
docker cp "$TEMP_CONTAINER:/dist/." "$TEMP_FRONTEND_DIR/"
docker rm "$TEMP_CONTAINER"

# Calculate frontend hashes
echo "🔍 Calculating frontend file hashes..."
cd "$TEMP_FRONTEND_DIR"
# Remove non-hashed duplicates (same as local build script)
rm -f main.js style.css

{
    echo "# SHA256 checksums for deterministic build verification"
    echo ""
    echo "## SHA256 checksums:"
    find . -type f -exec sha256sum {} \; | sort
} > "$TEMP_CHECKSUMS_DIR/frontend-hashes.txt"

cd - > /dev/null

echo ""
echo "🦀 Building WASM Docker Image..."
echo "================================="

# Build WASM Docker image
cd ..
WASM_CONTAINER_NAME="github-wasm-builder"
docker build --platform linux/amd64 -f my-canister-dashboard-rs/Dockerfile.build -t "$WASM_CONTAINER_NAME" .

# Extract WASM build artifacts
echo "📋 Extracting WASM build files..."
TEMP_CONTAINER=$(docker create "$WASM_CONTAINER_NAME")
docker cp "$TEMP_CONTAINER:/app/my-canister-dashboard-rs/wasm/." "$TEMP_WASM_DIR/"
docker rm "$TEMP_CONTAINER"

# Calculate WASM hashes
echo "🔍 Calculating WASM file hashes..."
cd "$TEMP_WASM_DIR"

{
    echo "# SHA256 checksums for deterministic build verification"
    echo ""
    echo "## SHA256 checksums:"
    sha256sum *.wasm | sort
} > "$TEMP_CHECKSUMS_DIR/wasm-hashes.txt"

cd - > /dev/null

echo ""
echo "🔐 Hash Verification"
echo "===================="

# Compare frontend hashes
echo "Verifying frontend hashes..."
FRONTEND_COMMITTED_HASHES="canister-dashboard-frontend/checksums/hashes.txt"
if [ ! -f "$FRONTEND_COMMITTED_HASHES" ]; then
    echo "❌ ERROR: Frontend committed hashes file not found: $FRONTEND_COMMITTED_HASHES"
    exit 1
fi

# Extract only the SHA256 lines for comparison
GITHUB_FRONTEND_SUMS=$(grep "^[a-f0-9]" "$TEMP_CHECKSUMS_DIR/frontend-hashes.txt" | sort)
COMMITTED_FRONTEND_SUMS=$(grep "^[a-f0-9]" "$FRONTEND_COMMITTED_HASHES" | sort)

if [ "$GITHUB_FRONTEND_SUMS" != "$COMMITTED_FRONTEND_SUMS" ]; then
    echo "❌ ERROR: Frontend hashes do not match!"
    echo ""
    echo "GitHub calculated hashes:"
    echo "$GITHUB_FRONTEND_SUMS"
    echo ""
    echo "Committed hashes:"
    echo "$COMMITTED_FRONTEND_SUMS"
    echo ""
    echo "Diff:"
    diff <(echo "$COMMITTED_FRONTEND_SUMS") <(echo "$GITHUB_FRONTEND_SUMS") || true
    exit 1
else
    echo "✅ Frontend hashes match!"
fi

# Compare WASM hashes
echo "Verifying WASM hashes..."
WASM_COMMITTED_HASHES="my-canister-dashboard-rs/wasm/hashes.txt"
if [ ! -f "$WASM_COMMITTED_HASHES" ]; then
    echo "❌ ERROR: WASM committed hashes file not found: $WASM_COMMITTED_HASHES"
    exit 1
fi

# Extract only the SHA256 lines for comparison
GITHUB_WASM_SUMS=$(grep "^[a-f0-9]" "$TEMP_CHECKSUMS_DIR/wasm-hashes.txt" | sort)
COMMITTED_WASM_SUMS=$(grep "^[a-f0-9]" "$WASM_COMMITTED_HASHES" | sort)

if [ "$GITHUB_WASM_SUMS" != "$COMMITTED_WASM_SUMS" ]; then
    echo "❌ ERROR: WASM hashes do not match!"
    echo ""
    echo "GitHub calculated hashes:"
    echo "$GITHUB_WASM_SUMS"
    echo ""
    echo "Committed hashes:"
    echo "$COMMITTED_WASM_SUMS"
    echo ""
    echo "Diff:"
    diff <(echo "$COMMITTED_WASM_SUMS") <(echo "$GITHUB_WASM_SUMS") || true
    exit 1
else
    echo "✅ WASM hashes match!"
fi

echo ""
echo "🎉 Success! All deterministic builds verified!"
echo "=============================================="
echo "✅ Frontend build reproducible"
echo "✅ WASM build reproducible" 
echo "✅ All checksums match committed hashes"