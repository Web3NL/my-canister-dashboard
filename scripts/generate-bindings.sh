#!/bin/bash

# Generate bindings for my-canister.did
didc bind --target ts my-canister-dashboard-rs/candid/my-canister.did > my-canister-dashboard-rs/candid/my-canister.did.d.ts

echo "TypeScript binding generation complete!"
