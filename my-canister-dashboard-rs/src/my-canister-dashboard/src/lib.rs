//! # Canister Dashboard
//!
//! A self-contained dashboard for Internet Computer canisters that provides
//! essential monitoring and management capabilities.
//!
//! ## ⚠️ Beta Warning
//!
//! **This crate is in BETA and NOT PRODUCTION READY.**
//!
//! - API may change without notice
//! - Not recommended for production use
//! - Use at your own risk
//! - Feedback and contributions welcome
//!
//! ## Features
//!
//! - Canister status monitoring
//! - Balance and cycles tracking
//! - Controller management
//! - Top-up functionality
//! - Alternative origins configuration
//!
//! ## Usage
//!
//! Add the dashboard assets to your canister:
//!
//! ```rust,no_run
//! use ic_asset_certification::AssetRouter;
//! use my_canister_dashboard::setup_dashboard_assets;
//!
//! let mut router = AssetRouter::default();
//! setup_dashboard_assets(&mut router).expect("Failed to setup dashboard");
//! ```

use ic_asset_certification::{Asset, AssetRouter};
use ic_cdk::api::{caller, is_controller, set_certified_data};
use include_dir::{Dir, include_dir};

mod alternative_origins;
mod asset_configs;
mod ii_principal;
mod wasm_status;

// Re-export only the essential types and main function
pub use alternative_origins::{
    UpdateAlternativeOriginsArg, UpdateAlternativeOriginsResult, update_alternative_origins,
};
pub use ii_principal::{UpdateIIPrincipalArg, UpdateIIPrincipalResult, update_ii_principal};
pub use wasm_status::WasmStatus;

static ASSETS_DIR: Dir<'_> = include_dir!("$CARGO_MANIFEST_DIR/../../../assets/frontend");

/// Checks if the caller is a controller of the canister.
///
/// # Returns
///
/// * `Ok(())` if the caller is a controller
/// * `Err(String)` if the caller is not a controller
///
/// # Example
///
/// ```rust,no_run
/// use my_canister_dashboard::only_canister_controllers_guard;
/// use ic_cdk::{query, update};
///
/// #[query(guard = "only_canister_controllers_guard")]
/// fn query() {
///     // Only controllers can call this function
/// }
///
/// #[update(guard = "only_canister_controllers_guard")]
/// fn update() {
///     // Only controllers can call this function
/// }
/// ```
pub fn only_canister_controllers_guard() -> Result<(), String> {
    if is_controller(&caller()) {
        Ok(())
    } else {
        Err("Caller is not a controller".to_string())
    }
}

/// Sets up dashboard assets in the provided AssetRouter.
///
/// This function adds the self-contained dashboard assets to your canister's asset router.
/// It leaves any existing assets untouched and only adds the dashboard assets.
/// The certified data is automatically updated with the new root hash.
///
/// # Arguments
///
/// * `router` - A mutable reference to the AssetRouter where dashboard assets will be added
///
/// # Returns
///
/// * `Ok(())` on success
/// * `Err(String)` if asset certification fails
///
/// # Example
///
/// ```rust,no_run
/// use ic_asset_certification::AssetRouter;
/// use my_canister_dashboard::setup_dashboard_assets;
///
/// # fn main() -> Result<(), String> {
/// let mut router = AssetRouter::default();
/// setup_dashboard_assets(&mut router)?;
/// # Ok(())
/// # }
/// ```
pub fn setup_dashboard_assets(router: &mut AssetRouter) -> Result<(), String> {
    let mut assets = Vec::new();
    let mut asset_configs = Vec::new();

    for file in ASSETS_DIR.files() {
        let path = file.path().to_string_lossy().to_string();
        let contents = file.contents();

        // Create asset with owned data
        assets.push(Asset::new(path.clone(), contents.to_vec()));

        // Create asset config using the discovered path
        let config = asset_configs::create_asset_config(&path);
        asset_configs.push(config);
    }

    // Certify the dashboard assets (this adds to any existing assets)
    router
        .certify_assets(assets, asset_configs)
        .map_err(|e| format!("Failed to certify dashboard assets: {e:?}"))?;

    // Update the certified data with the new root hash
    set_certified_data(&router.root_hash());

    Ok(())
}
