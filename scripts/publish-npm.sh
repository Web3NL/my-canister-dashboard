#!/bin/bash

# Publish script for @web3nl/my-canister-dashboard
# Automatically handles public access and beta tagging

set -e  # Exit on any error

echo "🚀 Publishing @web3nl/my-canister-dashboard..."

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

# Check if version contains beta/alpha/rc (prerelease)
if [[ $VERSION == *"beta"* ]] || [[ $VERSION == *"alpha"* ]] || [[ $VERSION == *"rc"* ]]; then
  echo "🧪 Detected prerelease version - publishing with beta tag"
  (cd my-canister-dashboard-js && npm publish --access public --tag beta)
else
  echo "✅ Publishing stable version with latest tag"
  (cd my-canister-dashboard-js && npm publish --access public)
fi

echo "🎉 Successfully published @web3nl/my-canister-dashboard@$VERSION!"
echo "📋 View at: https://npmjs.com/package/@web3nl/my-canister-dashboard"