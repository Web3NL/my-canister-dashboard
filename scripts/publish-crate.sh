#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Crate directory
RUST_CRATE_DIR="canister-dashboard-rs"

# Function to display usage
usage() {
    echo "Usage: $0 [--dry-run]"
    echo ""
    echo "This script will:"
    echo "  1. Publish Rust crate to crates.io"
    echo ""
    echo "Options:"
    echo "  --dry-run    Perform a dry run without actually publishing"
    exit 1
}

# Parse arguments
DRY_RUN=false
if [ $# -eq 1 ]; then
    if [ "$1" = "--dry-run" ]; then
        DRY_RUN=true
    else
        echo -e "${RED}Error: Invalid argument '$1'${NC}"
        usage
    fi
elif [ $# -gt 1 ]; then
    usage
fi

# Check if crate directory exists
if [ ! -d "$RUST_CRATE_DIR" ]; then
    echo -e "${RED}Error: Rust crate directory not found: $RUST_CRATE_DIR${NC}"
    exit 1
fi

# Check if Cargo.toml exists
if [ ! -f "$RUST_CRATE_DIR/Cargo.toml" ]; then
    echo -e "${RED}Error: Cargo.toml not found in $RUST_CRATE_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Publishing Rust crate to crates.io...${NC}"

# Change to crate directory and publish
cd "$RUST_CRATE_DIR"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🧪 Performing dry run...${NC}"
    cargo publish --dry-run || {
        echo -e "${RED}❌ Dry run failed${NC}"
        exit 1
    }
    echo -e "${GREEN}✅ Dry run completed successfully${NC}"
else
    cargo publish || {
        echo -e "${RED}❌ Failed to publish Rust crate to crates.io${NC}"
        echo -e "${YELLOW}⚠️  You may need to check:${NC}"
        echo -e "${YELLOW}    - Are you logged in to crates.io? (cargo login)${NC}"
        echo -e "${YELLOW}    - Does this version already exist?${NC}"
        echo -e "${YELLOW}    - Are there any compilation errors?${NC}"
        exit 1
    }
    echo -e "${GREEN}✅ Rust crate published to crates.io${NC}"
fi