use ic_asset_certification::{Asset, AssetRouter};
use ic_cdk::api::set_certified_data;
use include_dir::{include_dir, Dir};

mod alternative_origins;
mod asset_configs;

// Re-export only the essential types and main function
pub use alternative_origins::{
    update_alternative_origins, UpdateAlternativeOriginsArg, UpdateAlternativeOriginsResult,
};

static ASSETS_DIR: Dir<'_> = include_dir!("$CARGO_MANIFEST_DIR/assets");

/// Sets up dashboard assets in the provided AssetRouter.
/// Leaves any existing assets untouched and only adds the dashboard assets.
/// Automatically updates the certified data with the new root hash.
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
        .map_err(|e| format!("Failed to certify dashboard assets: {:?}", e))?;

    // Update the certified data with the new root hash
    set_certified_data(&router.root_hash());

    Ok(())
}
