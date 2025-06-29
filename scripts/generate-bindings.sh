#!/bin/bash

# Generate bindings for my-canister.did
echo "Generating DFX bindings..."
cd my-canister-dashboard-rs/
dfx generate my-canister

echo "Copying declarations to project root..."
cp -r declarations/* ../declarations/

echo "TypeScript and JavaScript binding generation complete!"
