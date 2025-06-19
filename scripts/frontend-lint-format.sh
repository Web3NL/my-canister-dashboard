#!/bin/bash

# Frontend linting and formatting script for canister-dashboard-frontend
# Runs from project root

set -e

# Ensure we're in the project root
if [ ! -f "package.json" ] || [ ! -d "canister-dashboard-frontend" ]; then
    echo "This script must be run from the project root directory"
    exit 1
fi

cd canister-dashboard-frontend

echo "🔍 Running security audit and fixing issues..."
npm run audit:fix
npm run audit

echo "✨ Formatting code..."
npm run format

echo "🔧 Linting and fixing issues..."
npm run lint:fix

echo "🏗️ Type checking..."
npm run typecheck

echo "📦 Building project..."
npm run build

echo "✅ Frontend lint, format, audit, and build completed successfully!"