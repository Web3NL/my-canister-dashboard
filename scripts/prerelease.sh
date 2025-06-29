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
./build-docker.sh

echo "✅ Prerelease build complete!"
echo "📁 Assets created in assets/"
echo "🔐 SHA256 checksums: assets/hashes.txt"