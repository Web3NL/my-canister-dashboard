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

// Export canister backend utilities directly from declarations
export { idlFactory, createActor, my_canister } from '$declarations/index.js';

// Export types and interfaces for the backend
export type { CreateActorOptions } from '$declarations/index.d';
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
