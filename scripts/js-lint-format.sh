#!/bin/bash

# JS package linting and formatting script for my-canister-dashboard-js
# Runs from project root

set -e

# Ensure we're in the project root
if [ ! -d "my-canister-dashboard-js" ] || [ ! -d "scripts" ]; then
    echo "This script must be run from the project root directory"
    exit 1
fi

cd my-canister-dashboard-js

echo "✨ Formatting code..."
npm run format

echo "🔧 Linting and fixing issues..."
npm run lint:fix

echo "🏗️ Type checking..."
npm run typecheck

echo "📦 Building package..."
npm run build

echo "✅ JS package lint, format, typecheck, and build completed successfully!"