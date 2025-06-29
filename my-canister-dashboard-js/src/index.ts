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

// Export canister backend utilities with sensible names
export { 
  idlFactory as MyCanisterIdlFactory, 
  createActor as createMyCanisterActor, 
  my_canister as myCanisterBackend 
} from '$declarations/index.js';

// Export types and interfaces for the backend
export type { CreateActorOptions as MyCanisterActorOptions } from '$declarations/index.d';
export type {
  _SERVICE as MyCanisterService,
  HttpRequest,
  HttpResponse,
  UpdateAlternativeOriginsArg,
  UpdateAlternativeOriginsResult,
  UpdateIIPrincipalArg,
  UpdateIIPrincipalResult,
  WasmStatus,
} from '$declarations/my-canister.did.d';
