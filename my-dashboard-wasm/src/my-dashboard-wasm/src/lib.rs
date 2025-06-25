use ic_asset_certification::AssetRouter;
use ic_cdk::api::data_certificate;
use ic_cdk::{init, post_upgrade, query, update};
use ic_http_certification::{HttpRequest, HttpResponse, StatusCode};
use my_canister_dashboard::{only_canister_controllers_guard, WasmStatus};
use std::borrow::Cow;
use std::cell::RefCell;

thread_local! {
    static ASSET_ROUTER: RefCell<AssetRouter<'static>> = RefCell::new(AssetRouter::default());
}

#[init]
fn init() {
    setup_assets();
}

#[post_upgrade]
fn post_upgrade() {
    setup_assets();
}

fn setup_assets() {
    ASSET_ROUTER.with(|router| {
        let mut router = router.borrow_mut();

        my_canister_dashboard::setup_dashboard_assets(&mut router)
            .expect("Failed to setup dashboard assets");
    });
}

#[query]
fn http_request(request: HttpRequest) -> HttpResponse {
    ASSET_ROUTER.with(|router| {
        let router = router.borrow();
        let data_certificate = data_certificate().unwrap_or_default();

        match router.serve_asset(&data_certificate, &request) {
            Ok(response) => response,
            Err(_) => HttpResponse::builder()
                .with_status_code(StatusCode::NOT_FOUND)
                .with_headers(vec![("Content-Type".to_string(), "text/plain".to_string())])
                .with_body(Cow::Owned("404 Not Found".as_bytes().to_vec()))
                .build(),
        }
    })
}

#[update(guard = "only_canister_controllers_guard")]
fn update_alternative_origins(
    arg: my_canister_dashboard::UpdateAlternativeOriginsArg,
) -> my_canister_dashboard::UpdateAlternativeOriginsResult {
    ASSET_ROUTER.with(|router| {
        let mut router = router.borrow_mut();
        my_canister_dashboard::update_alternative_origins(&mut router, arg)
    })
}

#[query(guard = "only_canister_controllers_guard")]
fn get_wasm_status() -> WasmStatus {
    WasmStatus {
        name: "My Dashboard WASM".to_string(),
        version: 1,
        memo: Some("Self-contained canister dashboard".to_string()),
    }
}
