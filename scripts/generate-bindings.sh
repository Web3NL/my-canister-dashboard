#!/bin/bash

# Generate TypeScript bindings from Candid files using didc

# Ensure the candid directory exists
if [ ! -d "candid" ]; then
    echo "Error: candid directory not found"
    exit 1
fi

# Generate bindings for my-canister.did
if [ -f "candid/my-canister.did" ]; then
    echo "Generating TypeScript bindings for my-canister..."
    didc bind --target ts candid/my-canister.did > candid/my-canister.did.d.ts
    echo "Generated candid/my-canister.did.d.ts"
else
    echo "Warning: candid/my-canister.did not found"
fi

echo "TypeScript binding generation complete!"