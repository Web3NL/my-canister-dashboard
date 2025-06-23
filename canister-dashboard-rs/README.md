# Canister Dashboard

A self-contained dashboard for Internet Computer canisters that provides essential monitoring and management capabilities.

## ⚠️ Beta Warning

**This crate is in BETA and NOT PRODUCTION READY.**

- API may change without notice
- Not recommended for production use  
- Use at your own risk
- Feedback and contributions welcome

## Features

- Canister status monitoring
- Balance and cycles tracking
- Controller management  
- Top-up functionality
- Alternative origins configuration

## Usage

Integrate the dashboard assets into your canister:

```rust
use ic_asset_certification::AssetRouter;
use my_canister_dashboard::setup_dashboard_assets;

let mut router = AssetRouter::default();
setup_dashboard_assets(&mut router).expect("Failed to setup dashboard");
```

## License

MIT