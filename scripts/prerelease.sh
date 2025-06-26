#!/bin/bash

set -e

echo "🚀 Running prerelease build..."

echo "🔍 Frontend lint..."
./scripts/frontend-lint-format.sh

echo "📦 Frontend deterministic build..."
(cd canister-dashboard-frontend && npm run build:deterministic)

echo "🦀 Rust lint..."
./scripts/rust-lint-format.sh

echo "⚙️  WASM deterministic build..."
(cd my-canister-dashboard-rs && ./build-deterministic.sh)

echo "🔐 Validating deterministic builds..."
echo "Checking that builds produce consistent results..."

# Store original checksums for comparison
FRONTEND_ORIGINAL_HASHES="/tmp/original-frontend-hashes.txt"
WASM_ORIGINAL_HASHES="/tmp/original-wasm-hashes.txt"

cp canister-dashboard-frontend/checksums/hashes.txt "$FRONTEND_ORIGINAL_HASHES" 2>/dev/null || echo "No existing frontend hashes found"
cp my-canister-dashboard-rs/checksums/hashes.txt "$WASM_ORIGINAL_HASHES" 2>/dev/null || echo "No existing WASM hashes found"

# Rebuild to test deterministic nature
echo "🔄 Running second build to verify determinism..."
echo "Frontend rebuild..."
(cd canister-dashboard-frontend && npm run build:deterministic)

echo "WASM rebuild..."
(cd my-canister-dashboard-rs && ./build-deterministic.sh)

# Compare checksums from first and second build
echo "📋 Comparing checksums..."
FRONTEND_REBUILD_HASHES="canister-dashboard-frontend/checksums/hashes.txt"
WASM_REBUILD_HASHES="my-canister-dashboard-rs/checksums/hashes.txt"

if [ -f "$FRONTEND_ORIGINAL_HASHES" ]; then
    if ! diff -q "$FRONTEND_ORIGINAL_HASHES" "$FRONTEND_REBUILD_HASHES" > /dev/null 2>&1; then
        echo "❌ ERROR: Frontend builds are not deterministic!"
        echo "First build vs second build differ:"
        diff "$FRONTEND_ORIGINAL_HASHES" "$FRONTEND_REBUILD_HASHES" || true
        exit 1
    else
        echo "✅ Frontend builds are deterministic"
    fi
fi

if [ -f "$WASM_ORIGINAL_HASHES" ]; then
    if ! diff -q "$WASM_ORIGINAL_HASHES" "$WASM_REBUILD_HASHES" > /dev/null 2>&1; then
        echo "❌ ERROR: WASM builds are not deterministic!"
        echo "First build vs second build differ:"
        diff "$WASM_ORIGINAL_HASHES" "$WASM_REBUILD_HASHES" || true
        exit 1
    else
        echo "✅ WASM builds are deterministic"
    fi
fi

# Cleanup
rm -f "$FRONTEND_ORIGINAL_HASHES" "$WASM_ORIGINAL_HASHES"

echo "🎉 All builds are deterministic and ready for commit!"
echo "✅ Prerelease build complete!"