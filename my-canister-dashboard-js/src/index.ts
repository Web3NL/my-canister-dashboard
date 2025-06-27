/**
 * My Canister Dashboard utilities for Internet Computer canisters
 */

// Export constants
export { LOW_CYCLES_THRESHOLD } from './constants';

// Export the main class
export { MyCanisterDashboard } from './dashboard';

// Export types and interfaces
export type {
  CheckCyclesBalanceOptions,
  CheckCyclesBalanceResult,
} from './dashboard';

// Export the backend class for canister interactions
export { MyCanisterBackend } from './myCanisterBackend';

// Export types and interfaces for the backend
export type {
  _SERVICE,
  HttpRequest,
  HttpResponse,
  UpdateAlternativeOriginsArg,
  UpdateAlternativeOriginsResult,
  UpdateIIPrincipalArg,
  UpdateIIPrincipalResult,
  WasmStatus,
} from '$declarations/my-canister.did.d';
