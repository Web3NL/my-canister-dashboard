use crate::asset_configs;
use crate::ASSETS_DIR;
use candid::CandidType;
use ic_asset_certification::{Asset, AssetRouter};
use ic_cdk::api::set_certified_data;
use serde::{Deserialize, Serialize};

#[derive(CandidType, Serialize, Deserialize)]
pub enum UpdateAlternativeOriginsArg {
    AddAlternativeOrigin(String),
    RemoveAlternativeOrigin(String),
}

#[derive(CandidType, Serialize, Deserialize)]
pub enum UpdateAlternativeOriginsResult {
    Ok,
    Err(String),
}

/// Unified method to update alternative origins matching the Candid interface
pub fn update_alternative_origins(
    router: &mut AssetRouter,
    arg: UpdateAlternativeOriginsArg,
) -> UpdateAlternativeOriginsResult {
    match arg {
        UpdateAlternativeOriginsArg::AddAlternativeOrigin(domain) => {
            match add_alternative_origin(router, domain) {
                Ok(_) => UpdateAlternativeOriginsResult::Ok,
                Err(e) => UpdateAlternativeOriginsResult::Err(e),
            }
        }
        UpdateAlternativeOriginsArg::RemoveAlternativeOrigin(domain) => {
            match remove_alternative_origin(router, domain) {
                Ok(_) => UpdateAlternativeOriginsResult::Ok,
                Err(e) => UpdateAlternativeOriginsResult::Err(e),
            }
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct AlternativeOrigins {
    #[serde(rename = "alternativeOrigins")]
    pub alternative_origins: Vec<String>,
}

impl AlternativeOrigins {
    fn new() -> Self {
        Self {
            alternative_origins: Vec::new(),
        }
    }

    fn from_json(json_str: &str) -> Result<Self, serde_json::Error> {
        serde_json::from_str(json_str)
    }

    fn to_json(&self) -> Result<String, serde_json::Error> {
        serde_json::to_string_pretty(self)
    }

    fn add_origin(&mut self, origin: String) -> bool {
        if !self.alternative_origins.contains(&origin) {
            self.alternative_origins.push(origin);
            true
        } else {
            false
        }
    }

    fn remove_origin(&mut self, origin: &str) -> bool {
        if let Some(pos) = self.alternative_origins.iter().position(|x| x == origin) {
            self.alternative_origins.remove(pos);
            true
        } else {
            false
        }
    }
}

/// Get the content of the ii-alternative-origins file for dynamic updates
fn get_ii_alternative_origins_content() -> Option<&'static [u8]> {
    for file in ASSETS_DIR.files() {
        let path = file.path().to_string_lossy().to_string();
        if path == "ii-alternative-origins" {
            return Some(file.contents());
        }
    }
    None
}

/// Get the current alternative origins from the embedded asset
fn get_current_alternative_origins() -> Result<AlternativeOrigins, String> {
    let contents =
        get_ii_alternative_origins_content().ok_or("ii-alternative-origins file not found")?;

    let contents_str = std::str::from_utf8(contents)
        .map_err(|_| "Failed to parse ii-alternative-origins as UTF-8")?;

    AlternativeOrigins::from_json(contents_str)
        .map_err(|e| format!("Failed to parse ii-alternative-origins JSON: {}", e))
}

/// Update the ii-alternative-origins asset in the router with new origins
fn update_alternative_origins_asset(
    router: &mut AssetRouter,
    updated_origins: &AlternativeOrigins,
) -> Result<(), String> {
    let updated_json = updated_origins
        .to_json()
        .map_err(|e| format!("Failed to serialize origins to JSON: {}", e))?;

    // Delete the existing ii-alternative-origins asset
    router.delete_assets_by_path(["ii-alternative-origins"]);

    // Create the updated ii-alternative-origins asset
    let asset = Asset::new(
        "ii-alternative-origins".to_string(),
        updated_json.as_bytes().to_vec(),
    );

    // Use the centralized config function
    let asset_config = asset_configs::ii_alternative_origins_config();

    // Certify only the updated asset
    router
        .certify_assets(vec![asset], vec![asset_config])
        .map_err(|e| format!("Failed to certify assets: {:?}", e))?;

    // Update the certified data
    set_certified_data(&router.root_hash());

    Ok(())
}

/// Add an alternative origin and update the asset in the router
fn add_alternative_origin(router: &mut AssetRouter, domain: String) -> Result<bool, String> {
    // Validate the domain format (basic validation)
    if domain.trim().is_empty() {
        return Err("Domain cannot be empty".to_string());
    }

    // Get current origins
    let mut origins = get_current_alternative_origins()?;

    // Try to add the new domain
    let was_added = origins.add_origin(domain);

    if was_added {
        // Update the asset in the router
        update_alternative_origins_asset(router, &origins)?;
        Ok(true)
    } else {
        Ok(false) // Domain already exists
    }
}

/// Remove an alternative origin and update the asset in the router
fn remove_alternative_origin(router: &mut AssetRouter, domain: String) -> Result<bool, String> {
    if domain.trim().is_empty() {
        return Err("Domain cannot be empty".to_string());
    }

    // Get current origins
    let mut origins = get_current_alternative_origins()?;

    // Try to remove the domain
    let was_removed = origins.remove_origin(&domain);

    if was_removed {
        // Update the asset in the router
        update_alternative_origins_asset(router, &origins)?;
        Ok(true)
    } else {
        Ok(false) // Domain didn't exist
    }
}

impl Default for AlternativeOrigins {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new() {
        let origins = AlternativeOrigins::new();
        assert_eq!(origins.alternative_origins.len(), 0);
    }

    #[test]
    fn test_from_json() {
        let json = r#"{"alternativeOrigins": ["http://localhost:5173", "https://example.com"]}"#;
        let origins = AlternativeOrigins::from_json(json).unwrap();
        assert_eq!(origins.alternative_origins.len(), 2);
        assert!(origins
            .alternative_origins
            .contains(&"http://localhost:5173".to_string()));
        assert!(origins
            .alternative_origins
            .contains(&"https://example.com".to_string()));
    }

    #[test]
    fn test_to_json() {
        let mut origins = AlternativeOrigins::new();
        origins.add_origin("http://localhost:5173".to_string());
        origins.add_origin("https://example.com".to_string());

        let json = origins.to_json().unwrap();
        assert!(json.contains("alternativeOrigins"));
        assert!(json.contains("http://localhost:5173"));
        assert!(json.contains("https://example.com"));
    }

    #[test]
    fn test_add_origin() {
        let mut origins = AlternativeOrigins::new();

        // Adding new origin should return true
        assert!(origins.add_origin("http://localhost:5173".to_string()));
        assert_eq!(origins.alternative_origins.len(), 1);

        // Adding duplicate origin should return false
        assert!(!origins.add_origin("http://localhost:5173".to_string()));
        assert_eq!(origins.alternative_origins.len(), 1);
    }

    #[test]
    fn test_remove_origin() {
        let mut origins = AlternativeOrigins::new();
        origins.add_origin("http://localhost:5173".to_string());
        origins.add_origin("https://example.com".to_string());

        // Removing existing origin should return true
        assert!(origins.remove_origin("http://localhost:5173"));
        assert_eq!(origins.alternative_origins.len(), 1);
        assert!(!origins
            .alternative_origins
            .contains(&"http://localhost:5173".to_string()));

        // Removing non-existing origin should return false
        assert!(!origins.remove_origin("http://nonexistent.com"));
        assert_eq!(origins.alternative_origins.len(), 1);
    }
}
