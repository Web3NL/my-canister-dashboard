use candid::{CandidType, Principal};
use serde::{Deserialize, Serialize};
use std::cell::RefCell;

/// Argument for updating or retrieving the Internet Identity principal
#[derive(CandidType, Serialize, Deserialize, Clone, Debug)]
pub enum UpdateIIPrincipalArg {
    /// Set a new Internet Identity principal
    Set(Principal),
    /// Get the current Internet Identity principal
    Get,
}

/// Result of Internet Identity principal operations
#[derive(CandidType, Serialize, Deserialize, Clone, Debug)]
pub enum UpdateIIPrincipalResult {
    /// Operation succeeded, returns principal for Get operations (None if not set)
    Ok(Option<Principal>),
    /// Operation failed with error message
    Err(String),
}

/// Updates or retrieves the Internet Identity principal from thread-local storage.
///
/// # Arguments
/// * `arg` - Operation to perform (Set or Get)
///
/// # Returns
/// * `UpdateIIPrincipalResult` - Result of the operation
pub fn update_ii_principal(arg: UpdateIIPrincipalArg) -> UpdateIIPrincipalResult {
    match arg {
        UpdateIIPrincipalArg::Set(principal) => {
            set_ii_principal(principal);
            UpdateIIPrincipalResult::Ok(None)
        }
        UpdateIIPrincipalArg::Get => {
            let principal = get_ii_principal();
            UpdateIIPrincipalResult::Ok(principal)
        }
    }
}

thread_local! {
    /// Thread-local storage for Internet Identity principal
    static II_PRINCIPAL: RefCell<Option<Principal>> = const { RefCell::new(None) };
}

/// Sets the Internet Identity principal in thread-local storage
fn set_ii_principal(principal: Principal) {
    II_PRINCIPAL.with(|p| {
        *p.borrow_mut() = Some(principal);
    });
}

/// Gets the Internet Identity principal from thread-local storage
fn get_ii_principal() -> Option<Principal> {
    II_PRINCIPAL.with(|p| *p.borrow())
}
