#!/bin/bash

set -e

echo "🚀 Starting complete publish process..."

# 1. Publish Rust crate
echo "📦 Step 1: Publishing Rust crate..."
./scripts/publish-crate.sh

# 2. Publish NPM package
echo "📦 Step 2: Publishing NPM package..."
./scripts/publish-npm.sh

# 3. Tag NPM as latest
echo "🏷️  Step 3: Tagging NPM as latest..."
./scripts/tag-npm-latest.sh

echo "🎉 All publish steps completed successfully!"