#!/bin/bash

set -e

echo "🚀 Running prerelease build..."

echo "🔍 Frontend lint..."
./scripts/frontend-lint-format.sh

echo "📦 Frontend deterministic build..."
cd canister-dashboard-frontend && npm run build:deterministic && cd ..

echo "🦀 Rust lint..."
./scripts/rust-lint-format.sh

echo "⚙️  WASM deterministic build..."
cd my-empty-wasm && ./build-deterministic.sh && cd ..

echo "✅ Prerelease build complete!"