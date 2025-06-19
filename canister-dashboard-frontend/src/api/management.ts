import {
  CanisterStatusResponse,
  ICManagementCanister,
} from '@dfinity/ic-management';
import { createHttpAgent, inferCanisterIdFromLocation } from '../utils';

export class ManagementApi {
  private async managmentApi(): Promise<ICManagementCanister> {
    const agent = await createHttpAgent();
    return ICManagementCanister.create({
      agent,
    });
  }

  async getCanisterStatus(): Promise<CanisterStatusResponse> {
    const icManagement = await this.managmentApi();
    const canisterId = inferCanisterIdFromLocation();

    return await icManagement!.canisterStatus(canisterId);
  }
}
