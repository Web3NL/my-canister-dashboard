import { Actor, HttpAgent, type ActorSubclass } from '@dfinity/agent';
import { Principal } from '@dfinity/principal';
import { idlFactory } from '$declarations/my-canister.did.js';
import type {
  _SERVICE as MyCanisterService,
  HttpRequest,
  HttpResponse,
  UpdateAlternativeOriginsArg,
  UpdateAlternativeOriginsResult,
  UpdateIIPrincipalArg,
  UpdateIIPrincipalResult,
  WasmStatus,
} from '$declarations/my-canister.did.d';

// Re-export types for convenience
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

export interface MyCanisterBackendConfig {
  agent: HttpAgent;
  canisterId: string | Principal;
}

export function createMyCanisterActor(
  config: MyCanisterBackendConfig
): ActorSubclass<MyCanisterService> {
  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
  if (!config.agent) {
    throw new Error('agent is required');
  }

  if (!config.canisterId) {
    throw new Error('canisterId is required');
  }

  // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
  return Actor.createActor(idlFactory, {
    agent: config.agent,
    canisterId: config.canisterId,
  });
}

/**
n * MyCanisterBackend class for canister interactions
 */
export class MyCanisterBackend {
  private actor: ActorSubclass<MyCanisterService>;

  private constructor(actor: ActorSubclass<MyCanisterService>) {
    this.actor = actor;
  }

  /**
   * Create a new MyCanisterBackend instance
   */
  static create(config: MyCanisterBackendConfig): MyCanisterBackend {
    const actor = createMyCanisterActor(config);
    return new MyCanisterBackend(actor);
  }

  /**
   * Handle HTTP requests to the canister
   */
  async httpRequest(request: HttpRequest): Promise<HttpResponse> {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call
    return await this.actor.http_request(request);
  }

  /**
   * Update alternative origins for the canister
   */
  async updateAlternativeOrigins(
    arg: UpdateAlternativeOriginsArg
  ): Promise<UpdateAlternativeOriginsResult> {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call
    return await this.actor.update_alternative_origins(arg);
  }

  /**
   * Update or get the Internet Identity principal
   */
  async updateIIPrincipal(
    arg: UpdateIIPrincipalArg
  ): Promise<UpdateIIPrincipalResult> {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call
    return await this.actor.update_ii_principal(arg);
  }

  /**
   * Get the WASM status of the canister
   */
  async wasmStatus(): Promise<WasmStatus> {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call
    return await this.actor.wasm_status();
  }
}
