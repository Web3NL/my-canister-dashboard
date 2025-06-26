import { ActorSubclass, Actor } from '@dfinity/agent';
import {
  _SERVICE as CanisterApiService,
  idlFactory,
  UpdateAlternativeOriginsArg,
  UpdateAlternativeOriginsResult,
} from '../../../my-canister-dashboard-rs/candid/my-canister.did.d';
import { createHttpAgent } from '../utils';
import { inferCanisterIdFromLocation } from '../utils';

export class CanisterApi {
  private canisterApi: ActorSubclass<CanisterApiService> | null = null;

  constructor() {
    this.init();
  }

  private async init(): Promise<void> {
    const agent = await createHttpAgent();
    const canisterId = inferCanisterIdFromLocation();

    this.canisterApi = Actor.createActor(idlFactory, {
      agent,
      canisterId,
    }) as ActorSubclass<CanisterApiService>;
  }

  async updateAlternativeOrigins(
    arg: UpdateAlternativeOriginsArg
  ): Promise<UpdateAlternativeOriginsResult> {
    return await this.canisterApi!.update_alternative_origins(arg);
  }
}
