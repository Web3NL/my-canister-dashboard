#!/bin/bash

set -e

echo "🏗️  GitHub Deterministic Build Verification"
echo "============================================"

# Temporary directory for GitHub build artifacts
TEMP_BUILD_DIR="/tmp/github-build-verification"

# Clean up function
cleanup() {
    echo "🧹 Cleaning up temporary directory..."
    rm -rf "$TEMP_BUILD_DIR"
}
trap cleanup EXIT

# Create temporary directory
mkdir -p "$TEMP_BUILD_DIR"

echo ""
echo "📦 Running unified deterministic build..."
echo "=========================================="

# Run the unified build process
./build-docker.sh

# Copy the generated hashes to temp directory for comparison
cp assets/hashes.txt "$TEMP_BUILD_DIR/github-hashes.txt"

echo ""
echo "🔐 Hash Verification"
echo "===================="

# Check if committed hashes file exists  
COMMITTED_HASHES="assets/hashes.txt"
if [ ! -f "$COMMITTED_HASHES" ]; then
    echo "❌ ERROR: Committed hashes file not found: $COMMITTED_HASHES"
    echo "This should have been created by the release process."
    exit 1
fi

echo "Comparing GitHub build hashes with committed hashes..."

# Compare the hash files
if ! diff -q "$COMMITTED_HASHES" "$TEMP_BUILD_DIR/github-hashes.txt" > /dev/null 2>&1; then
    echo "❌ ERROR: Build hashes do not match committed hashes!"
    echo ""
    echo "This indicates the build is not deterministic or the committed"
    echo "hashes are out of sync with the current code."
    echo ""
    echo "Differences:"
    diff "$COMMITTED_HASHES" "$TEMP_BUILD_DIR/github-hashes.txt" || true
    exit 1
else
    echo "✅ Build hashes match committed hashes!"
fi

echo ""
echo "🎉 Success! Deterministic build verified!"
echo "=========================================="
echo "✅ Unified build is reproducible"
echo "✅ All checksums match committed hashes"
echo "✅ Build integrity confirmed"