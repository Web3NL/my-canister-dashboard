#!/bin/bash

# Rust linting and formatting script for my-canister-dashboard-rs
# Runs from project root

set -e

# Ensure we're in the project root
if [ ! -d "my-canister-dashboard-rs" ] || [ ! -d "scripts" ]; then
    echo "This script must be run from the project root directory"
    exit 1
fi

cd my-canister-dashboard-rs

cargo fmt
cargo clippy --all-targets --all-features -- -D warnings
cargo check --all-targets --all-features
cargo test