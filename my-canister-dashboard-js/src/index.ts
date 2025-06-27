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

// Export candid definitions
export type { _SERVICE } from '$declarations/my-canister.did.d';
export type {
  HttpRequest,
  HttpResponse,
  UpdateAlternativeOriginsArg,
  UpdateAlternativeOriginsResult,
  UpdateIIPrincipalArg,
  UpdateIIPrincipalResult,
  WasmStatus,
} from '../../declarations/my-canister.did.d';
export { idlFactory } from '../../declarations/my-canister.did.d';
