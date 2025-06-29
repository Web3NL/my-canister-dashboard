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

// Export canister backend class and utilities
export { MyCanisterBackend, createMyCanisterActor } from './actor';

// Export types and interfaces for the backend
export type {
  MyCanisterBackendConfig,
  MyCanisterService,
  HttpRequest,
  HttpResponse,
  UpdateAlternativeOriginsArg,
  UpdateAlternativeOriginsResult,
  UpdateIIPrincipalArg,
  UpdateIIPrincipalResult,
  WasmStatus,
} from './actor';
