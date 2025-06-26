#!/bin/bash

# Generate bindings for my-canister.did
didc bind --target ts candid/my-canister.did > candid/my-canister.did.d.ts

echo "TypeScript binding generation complete!"
