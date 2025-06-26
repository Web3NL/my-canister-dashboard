#!/bin/bash

# Rust linting and formatting script for my-dashboard-wasm
# Runs from project root

set -e

# Ensure we're in the project root
if [ ! -d "my-dashboard-wasm" ] || [ ! -d "scripts" ]; then
    echo "This script must be run from the project root directory"
    exit 1
fi

cd my-dashboard-wasm

cargo fmt
cargo clippy --all-targets --all-features -- -D warnings
cargo check --all-targets --all-features
cargo test