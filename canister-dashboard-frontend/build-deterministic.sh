#!/bin/bash

set -e

DIST_DIR="./dist"
RS_ASSETS_DIR="../my-canister-dashboard-rs/src/my-canister-dashboard/assets"
CHECKSUMS_DIR="./checksums"
CONTAINER_NAME="my-canister-dashboard-builder"

echo "🏗️  Building deterministic frontend..."

# Clean previous builds
rm -rf "$DIST_DIR"
rm -rf "$RS_ASSETS_DIR"
rm -rf "$CHECKSUMS_DIR"
mkdir -p "$DIST_DIR"
mkdir -p "$RS_ASSETS_DIR"
mkdir -p "$CHECKSUMS_DIR"

# Build container with build files only
echo "📦 Building Docker image..."
docker build --platform linux/amd64 -f Dockerfile.build -t "$CONTAINER_NAME" .

# Create temporary container to extract files
echo "📋 Extracting build files..."
TEMP_CONTAINER=$(docker create "$CONTAINER_NAME")
docker cp "$TEMP_CONTAINER:/dist/." "$DIST_DIR/"
docker rm "$TEMP_CONTAINER"

# Remove non-hashed duplicates (keep only hashed versions for JS/CSS)
echo "🧹 Cleaning duplicate files..."
cd "$DIST_DIR"
rm -f main.js style.css

# Calculate hashes BEFORE copying to Rust assets
echo "🔍 Calculating file hashes..."

# Generate hash manifest (using absolute path)
{
    echo "# SHA256 checksums for deterministic build verification"
    echo ""
    
    echo "## SHA256 checksums:"
    find . -type f -exec sha256sum {} \; | sort
    
    
} > "../$CHECKSUMS_DIR/hashes.txt"

# Copy cleaned files to Rust assets directory (after hash calculation)
echo "📋 Copying assets to Rust directory..."
cp -r ./* "../$RS_ASSETS_DIR/"

# Go back to original directory
cd ..

echo ""
echo "✅ Deterministic build complete!"
echo "📁 Build files: $DIST_DIR/"
echo "🔐 Hashes: $CHECKSUMS_DIR/hashes.txt"
echo ""
echo "Build verification:"
cat "$CHECKSUMS_DIR/hashes.txt"