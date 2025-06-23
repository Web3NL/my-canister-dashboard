#!/bin/bash

# Tag current package version as latest
# This script reads the current version from package.json and tags it as latest on npm

set -e  # Exit on any error

echo "🏷️  Tagging current version as latest..."

# Check if package.json exists
if [ ! -f "my-canister-dashboard-js/package.json" ]; then
  echo "❌ package.json not found in my-canister-dashboard-js/"
  exit 1
fi

# Check if logged in to npm
if ! npm whoami > /dev/null 2>&1; then
  echo "❌ Not logged in to npm. Please run 'npm login' first."
  exit 1
fi

# Get current version from package.json
VERSION=$(node -p "require('./my-canister-dashboard-js/package.json').version")
echo "📦 Current version: $VERSION"

# Tag the current version as latest
echo "🚀 Tagging @web3nl/my-canister-dashboard@$VERSION as latest..."
npm dist-tag add "@web3nl/my-canister-dashboard@$VERSION" latest

echo "✅ Successfully tagged @web3nl/my-canister-dashboard@$VERSION as latest!"
echo "📋 View at: https://npmjs.com/package/@web3nl/my-canister-dashboard"