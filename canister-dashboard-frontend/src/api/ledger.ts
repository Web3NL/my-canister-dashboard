import { LedgerCanister, AccountIdentifier } from '@dfinity/ledger-icp';
import { Principal } from '@dfinity/principal';
import { createHttpAgent } from '../utils';

export class LedgerApi {
  private async ledgerApi(): Promise<LedgerCanister> {
    const agent = await createHttpAgent();
    return LedgerCanister.create({
      agent,
    });
  }

  async balance(): Promise<bigint> {
    const agent = await createHttpAgent();
    const principal = await agent.getPrincipal();
    const accountIdentifier = AccountIdentifier.fromPrincipal({
      principal,
    });
    const ledger = await this.ledgerApi();
    return await ledger.accountBalance({
      accountIdentifier,
      certified: true,
    });
  }

  async transfer(
    to: Principal,
    subAccount: Uint8Array,
    amount: bigint,
    memo: Uint8Array,
    fee: bigint
  ): Promise<bigint> {
    const ledger = await this.ledgerApi();

    return await ledger.icrc1Transfer({
      to: {
        owner: to,
        subaccount: [subAccount],
      },
      amount,
      icrc1Memo: memo,
      fee: fee,
    });
  }
}
