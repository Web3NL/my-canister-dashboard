import { Actor, HttpAgent, type ActorSubclass } from '@dfinity/agent';
import { idlFactory } from '$declarations/my-canister.did.js';
import type {
  _SERVICE,
  HttpRequest,
  HttpResponse,
  UpdateAlternativeOriginsArg,
  UpdateAlternativeOriginsResult,
  UpdateIIPrincipalArg,
  UpdateIIPrincipalResult,
  WasmStatus,
} from '$declarations/my-canister.did.d';
import { Principal } from '@dfinity/principal';

export class MyCanisterBackend {
  private canisterInstaller: ActorSubclass<_SERVICE>;

  private constructor(canisterInstaller: ActorSubclass<_SERVICE>) {
    this.canisterInstaller = canisterInstaller;
  }

  static create(canisterId: Principal, agent: HttpAgent): MyCanisterBackend {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
    const canisterInstaller = Actor.createActor<_SERVICE>(idlFactory, {
      agent,
      canisterId,
    });
    return new MyCanisterBackend(canisterInstaller);
  }

  async http_request(request: HttpRequest): Promise<HttpResponse> {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call
    return await this.canisterInstaller.http_request(request);
  }

  async update_alternative_origins(
    arg: UpdateAlternativeOriginsArg
  ): Promise<UpdateAlternativeOriginsResult> {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call
    return await this.canisterInstaller.update_alternative_origins(arg);
  }

  async update_ii_principal(
    arg: UpdateIIPrincipalArg
  ): Promise<UpdateIIPrincipalResult> {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call
    return await this.canisterInstaller.update_ii_principal(arg);
  }

  async wasm_status(): Promise<WasmStatus> {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call
    return await this.canisterInstaller.wasm_status();
  }
}
