#!/bin/bash

# Rust linting and formatting script for canister-dashboard-rs
# Runs from project root

set -e

# Ensure we're in the project root
if [ ! -f "package.json" ] || [ ! -d "canister-dashboard-rs" ]; then
    echo "This script must be run from the project root directory"
    exit 1
fi

cd canister-dashboard-rs

cargo fmt --check
cargo clippy --all-targets --all-features -- -D warnings
cargo check --all-targets --all-features
cargo test