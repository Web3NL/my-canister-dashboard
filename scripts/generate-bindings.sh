#!/bin/bash

# Generate bindings for my-canister.did
didc bind --target ts my-dashboard-wasm/candid/my-canister.did > my-dashboard-wasm/candid/my-canister.did.d.ts

echo "TypeScript binding generation complete!"
