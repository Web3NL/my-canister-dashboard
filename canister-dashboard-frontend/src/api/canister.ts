import { ActorSubclass, Actor } from '@dfinity/agent';
import {
  _SERVICE,
  idlFactory,
  UpdateAlternativeOriginsArg,
  UpdateAlternativeOriginsResult,
} from '$declarations/my-canister.did';

type CanisterApiService = _SERVICE;
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

    // eslint-disable-next-line @typescript-eslint/no-unnecessary-type-assertion, @typescript-eslint/no-unsafe-argument
    this.canisterApi = Actor.createActor(idlFactory, {
      agent,
      canisterId,
    }) as ActorSubclass<CanisterApiService>;
  }

  async updateAlternativeOrigins(
    arg: UpdateAlternativeOriginsArg
  ): Promise<UpdateAlternativeOriginsResult> {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-call
    return await this.canisterApi!.update_alternative_origins(arg);
  }
}
