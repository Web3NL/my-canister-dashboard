#!/bin/bash

# Generate bindings for my-canister.did
didc bind --target ts my-canister-dashboard-rs/src/candid/my-canister.did > declarations/my-canister.did.d.ts
didc bind --target js my-canister-dashboard-rs/src/candid/my-canister.did > declarations/my-canister.did.js

echo "TypeScript and JavaScript binding generation complete!"
