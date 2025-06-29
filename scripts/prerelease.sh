#!/bin/bash

set -e

echo "🚀 Running prerelease build..."

echo "🔍 Frontend lint and format..."
./scripts/frontend-lint-format.sh

echo "📦 JS package lint and format..."
./scripts/js-lint-format.sh

echo "🦀 Rust lint and format..."
./scripts/rust-lint-format.sh

echo "🏗️  Running unified deterministic build..."
(cd my-canister-dashboard-rs && ./build-deterministic.sh)

echo "✅ Prerelease build complete!"
echo "📁 Assets created in my-canister-dashboard-rs/assets/"
echo "🔐 SHA256 checksums: my-canister-dashboard-rs/assets/hashes.txt"