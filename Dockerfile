
# Stage 1: Build frontend with official Node.js image
FROM node:lts-alpine3.21@sha256:a7c10fad0b8fa59578bf3cd1717b168df134db8362b89e1ea6f54676fee49d3b AS frontend-builder

WORKDIR /app/canister-dashboard-frontend

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001 -G nodejs

# Copy package files and install dependencies
COPY canister-dashboard-frontend/package*.json ./
RUN npm ci

# Copy source and build
COPY canister-dashboard-frontend/ ./
RUN npm run build

# Change ownership
RUN chown -R nodejs:nodejs /app/canister-dashboard-frontend/dist

# Stage 2: Build Rust and combine assets
FROM rust:1.87.0 AS rust-builder

# Setup Rust toolchain
RUN rustup target add wasm32-unknown-unknown

# Create non-root user for security
RUN groupadd -g 1001 builder && useradd -r -u 1001 -g builder builder

WORKDIR /app

# Copy Rust project
COPY my-canister-dashboard-rs/ ./my-canister-dashboard-rs/

# Copy frontend assets from previous stage and create assets structure BEFORE Rust compilation
COPY --from=frontend-builder --chown=builder:builder /app/canister-dashboard-frontend/dist ./frontend-assets/

# Create unified assets structure with frontend assets
RUN mkdir -p /app/assets/frontend && \
    cp -r ./frontend-assets/* /app/assets/frontend/

# Build Rust crate (now that assets exist)
WORKDIR /app/my-canister-dashboard-rs
RUN cargo build --target wasm32-unknown-unknown --release --package my-canister-installer --locked

# Add WASM to assets structure
RUN mkdir -p /app/assets/wasm && \
    cp target/wasm32-unknown-unknown/release/my_canister_installer.wasm /app/assets/wasm/my-canister-installer.wasm

# Change ownership of final assets
RUN chown -R builder:builder /app/assets

USER builder

WORKDIR /app
