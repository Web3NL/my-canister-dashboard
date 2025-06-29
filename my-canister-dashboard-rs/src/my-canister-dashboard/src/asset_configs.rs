use ic_asset_certification::{AssetConfig, AssetEncoding};

/// Create appropriate asset config based on file path
pub fn create_asset_config(path: &str) -> AssetConfig {
    match path {
        "index.html" => canister_dashboard_html_config(),
        "ii-alternative-origins" => ii_alternative_origins_config(),
        p if p.ends_with(".js") => dashboard_js_config(p.to_string()),
        p if p.ends_with(".css") => dashboard_css_config(p.to_string()),
        _ => panic!("Unsupported asset type: {path}"),
    }
}

/// Create asset config for ii-alternative-origins file
pub fn ii_alternative_origins_config() -> AssetConfig {
    AssetConfig::File {
        path: "ii-alternative-origins".to_string(),
        content_type: Some("application/json".to_string()),
        headers: vec![],
        fallback_for: vec![],
        aliased_by: vec!["/.well-known/ii-alternative-origins".to_string()],
        encodings: vec![(AssetEncoding::Identity, "".to_string())],
    }
}

/// Create asset config for index.html
fn canister_dashboard_html_config() -> AssetConfig {
    AssetConfig::File {
        path: "index.html".to_string(),
        content_type: Some("text/html".to_string()),
        headers: vec![],
        fallback_for: vec![],
        aliased_by: vec!["/canister-dashboard".to_string()],
        encodings: vec![(AssetEncoding::Identity, "".to_string())],
    }
}

/// Create asset config for JS files
fn dashboard_js_config(path: String) -> AssetConfig {
    let alias_path = format!("/canister-dashboard/{path}");
    AssetConfig::File {
        path,
        content_type: Some("application/javascript".to_string()),
        headers: vec![],
        fallback_for: vec![],
        aliased_by: vec![alias_path],
        encodings: vec![(AssetEncoding::Identity, "".to_string())],
    }
}

/// Create asset config for CSS files
fn dashboard_css_config(path: String) -> AssetConfig {
    let alias_path = format!("/canister-dashboard/{path}");
    AssetConfig::File {
        path,
        content_type: Some("text/css".to_string()),
        headers: vec![],
        fallback_for: vec![],
        aliased_by: vec![alias_path],
        encodings: vec![(AssetEncoding::Identity, "".to_string())],
    }
}
