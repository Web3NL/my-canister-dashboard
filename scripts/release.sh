#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Version files
FRONTEND_PACKAGE_JSON="canister-dashboard-frontend/package.json"
JS_PACKAGE_JSON="my-canister-dashboard-js/package.json"
RUST_CARGO_TOML="my-canister-dashboard-rs/src/my-canister-dashboard/Cargo.toml"
WASM_CARGO_TOML="my-canister-dashboard-rs/src/my-dashboard-wasm/Cargo.toml"

# Function to display usage
usage() {
    echo "Usage: $0 <patch|minor|major> [--beta]"
    echo ""
    echo "This script will:"
    echo "  1. Update versions in all subprojects"
    echo "  2. Run prerelease checks"
    echo "  3. Commit changes"
    echo "  4. Create and push git tag"
    echo ""
    echo "Examples:"
    echo "  $0 patch        # 0.1.0 -> 0.1.1"
    echo "  $0 minor        # 0.1.0 -> 0.2.0"
    echo "  $0 major        # 0.1.0 -> 1.0.0"
    echo "  $0 minor --beta # 0.1.0 -> 0.2.0-beta.1"
    exit 1
}

# Function to parse version
parse_version() {
    local version=$1
    echo $version | tr '.' ' '
}

# Function to increment version
increment_version() {
    local version=$1
    local bump_type=$2
    local is_beta=$3
    
    # Parse current version to detect if it's already a beta
    local clean_version
    local current_beta_num=""
    local is_current_beta=false
    
    if [[ $version =~ ^(.+)-beta\.([0-9]+)$ ]]; then
        clean_version="${BASH_REMATCH[1]}"
        current_beta_num="${BASH_REMATCH[2]}"
        is_current_beta=true
    else
        clean_version="$version"
        is_current_beta=false
    fi
    
    read -r major minor patch <<< $(parse_version $clean_version)
    
    # If --beta flag is set and current is beta and we're doing a patch bump,
    # just increment the beta number without changing the base version
    if [ "$is_beta" = true ] && [ "$is_current_beta" = true ] && [ "$bump_type" = "patch" ]; then
        local new_beta_num=$((current_beta_num + 1))
        echo "$clean_version-beta.$new_beta_num"
        return
    fi
    
    # Otherwise, bump the base version according to bump_type
    case $bump_type in
        "patch")
            patch=$((patch + 1))
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        *)
            echo -e "${RED}Error: Invalid bump type: $bump_type${NC}"
            exit 1
            ;;
    esac
    
    local new_version="$major.$minor.$patch"
    
    # Add beta suffix if requested
    if [ "$is_beta" = true ]; then
        new_version="$new_version-beta.1"
    fi
    
    echo "$new_version"
}

# Function to get current version from package.json
get_package_json_version() {
    local file=$1
    grep '"version"' "$file" | sed 's/.*"version": *"\([^"]*\)".*/\1/'
}

# Function to get current version from Cargo.toml
get_cargo_toml_version() {
    local file=$1
    grep '^version = ' "$file" | sed 's/version = "\([^"]*\)"/\1/'
}

# Function to update package.json version
update_package_json_version() {
    local file=$1
    local new_version=$2
    
    # Use sed to replace version in package.json
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/\"version\": *\"[^\"]*\"/\"version\": \"$new_version\"/" "$file"
    else
        # Linux
        sed -i "s/\"version\": *\"[^\"]*\"/\"version\": \"$new_version\"/" "$file"
    fi
}

# Function to update Cargo.toml version
update_cargo_toml_version() {
    local file=$1
    local new_version=$2
    
    # Use sed to replace version in Cargo.toml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^version = \"[^\"]*\"/version = \"$new_version\"/" "$file"
    else
        # Linux
        sed -i "s/^version = \"[^\"]*\"/version = \"$new_version\"/" "$file"
    fi
}

# Check arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    usage
fi

BUMP_TYPE=$1
IS_BETA=false

# Check for beta flag
if [ $# -eq 2 ]; then
    if [ "$2" = "--beta" ]; then
        IS_BETA=true
    else
        echo -e "${RED}Error: Invalid second argument '$2'. Only '--beta' is supported.${NC}"
        usage
    fi
fi

# Validate bump type
case $BUMP_TYPE in
    "patch"|"minor"|"major")
        ;;
    *)
        echo -e "${RED}Error: Invalid bump type '$BUMP_TYPE'${NC}"
        usage
        ;;
esac

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi



# Check if working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}Error: Working directory is not clean. Please commit or stash changes first.${NC}"
    git status --short
    exit 1
fi

# Check if all version files exist
for file in "$FRONTEND_PACKAGE_JSON" "$JS_PACKAGE_JSON" "$RUST_CARGO_TOML" "$WASM_CARGO_TOML"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: Version file not found: $file${NC}"
        exit 1
    fi
done

echo -e "${BLUE}🚀 Starting release process...${NC}"

# Get current versions
echo -e "${YELLOW}📋 Current versions:${NC}"
FRONTEND_VERSION=$(get_package_json_version "$FRONTEND_PACKAGE_JSON")
JS_VERSION=$(get_package_json_version "$JS_PACKAGE_JSON")
RUST_VERSION=$(get_cargo_toml_version "$RUST_CARGO_TOML")
WASM_VERSION=$(get_cargo_toml_version "$WASM_CARGO_TOML")

echo "  Frontend: $FRONTEND_VERSION"
echo "  JS Package: $JS_VERSION"
echo "  Rust Backend: $RUST_VERSION"
echo "  WASM Module: $WASM_VERSION"

# Check if all versions are the same
if [ "$FRONTEND_VERSION" != "$JS_VERSION" ] || [ "$FRONTEND_VERSION" != "$RUST_VERSION" ] || [ "$FRONTEND_VERSION" != "$WASM_VERSION" ]; then
    echo -e "${RED}Error: Version mismatch detected. All subprojects should have the same version.${NC}"
    exit 1
fi

CURRENT_VERSION=$FRONTEND_VERSION
NEW_VERSION=$(increment_version "$CURRENT_VERSION" "$BUMP_TYPE" "$IS_BETA")

if [ "$IS_BETA" = true ]; then
    echo -e "${YELLOW}🔄 Bumping version (BETA): $CURRENT_VERSION -> $NEW_VERSION${NC}"
else
    echo -e "${YELLOW}🔄 Bumping version: $CURRENT_VERSION -> $NEW_VERSION${NC}"
fi

# Update all version files
echo -e "${BLUE}📝 Updating version files...${NC}"
update_package_json_version "$FRONTEND_PACKAGE_JSON" "$NEW_VERSION"
update_package_json_version "$JS_PACKAGE_JSON" "$NEW_VERSION"
update_cargo_toml_version "$RUST_CARGO_TOML" "$NEW_VERSION"
update_cargo_toml_version "$WASM_CARGO_TOML" "$NEW_VERSION"

echo -e "${GREEN}✅ Version files updated${NC}"

# Run prerelease checks
echo -e "${BLUE}🔍 Running prerelease checks...${NC}"
./scripts/prerelease.sh

echo -e "${GREEN}✅ Prerelease checks passed${NC}"

# Commit changes
echo -e "${BLUE}💾 Committing changes...${NC}"
git add "$FRONTEND_PACKAGE_JSON" "$JS_PACKAGE_JSON" "$RUST_CARGO_TOML" "$WASM_CARGO_TOML"

# Also commit any build artifacts that were updated by prerelease.sh
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}📦 Adding build artifacts updated by prerelease checks...${NC}"
    git add -A
fi

git commit -m "Bump version to $NEW_VERSION

- Update version in all subprojects
- Update build artifacts and checksums
- Update lock files"

echo -e "${GREEN}✅ Changes committed${NC}"

# Create annotated tag
echo -e "${BLUE}🏷️  Creating tag v$NEW_VERSION...${NC}"
git tag -a "v$NEW_VERSION" -m "Release version $NEW_VERSION"

echo -e "${GREEN}✅ Tag created${NC}"

# Push to remote
echo -e "${BLUE}🚀 Pushing to remote...${NC}"
git push origin main
git push origin "v$NEW_VERSION"

echo -e "${GREEN}✅ Pushed to remote${NC}"


echo ""
echo -e "${GREEN}🎉 Release $NEW_VERSION completed successfully!${NC}"
echo ""
echo "Summary:"
echo "  - Version bumped from $CURRENT_VERSION to $NEW_VERSION"
echo "  - All prerelease checks passed"
echo "  - Changes committed and tagged"
echo "  - Pushed to remote repository"
echo ""
echo "The CI workflow will now run for tag v$NEW_VERSION"