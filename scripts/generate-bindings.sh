#!/bin/bash

# Generate bindings for my-canister.did
didc bind --target ts my-canister-dashboard-rs/src/candid/my-canister.did > declarations/my-canister.did.d.ts

echo "TypeScript binding generation complete!"
