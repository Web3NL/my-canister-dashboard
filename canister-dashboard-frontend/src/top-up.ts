import { LedgerApi } from './api/ledger';
import { CMCApi } from './api/cmc';
import { ICP_TX_FEE, TPUP_MEMO, CMC_CANISTER_ID } from './config';
import { inferCanisterIdFromLocation, principalToSubaccount } from './utils';
import { showLoading, hideLoading } from './loading';
import { Principal } from '@dfinity/principal';

export async function topUp(): Promise<void> {
  // Show loading
  showLoading();

  // Check balance
  const hasEnoughBalance = await checkBalanceForTopUp();
  if (!hasEnoughBalance) {
    hideLoading();
    return;
  }

  // Get current balance and calculate transfer amount
  const ledgerApi = new LedgerApi();
  const balance = await ledgerApi.balance();
  const transferAmount = balance - ICP_TX_FEE;

  // Transfer to CMC
  const blockHeight = await transferToCMC(transferAmount);

  // Notify CMC of top-up
  const cmcApi = new CMCApi();
  const canisterId = inferCanisterIdFromLocation().toString();
  await cmcApi.notifyTopUp(canisterId, blockHeight);

  // Hide loading
  hideLoading();

  // Reload page to reflect updated balance
  window.location.reload();
}

async function checkBalanceForTopUp(): Promise<boolean> {
  const ledgerApi = new LedgerApi();
  const balance = await ledgerApi.balance();

  // Balance should be at least 3 times the transaction fee
  const minimumBalance = ICP_TX_FEE * 3n;

  return balance >= minimumBalance;
}

async function transferToCMC(amount: bigint): Promise<bigint> {
  const ledgerApi = new LedgerApi();

  // Get canister ID and convert to subaccount
  const canisterId = inferCanisterIdFromLocation();
  const subaccount = principalToSubaccount(canisterId);

  // Send transfer to CMC canister with canister ID as subaccount
  const cmcPrincipal = Principal.fromText(CMC_CANISTER_ID);
  const blockHeight = await ledgerApi.transfer(
    cmcPrincipal,
    subaccount,
    amount,
    TPUP_MEMO,
    ICP_TX_FEE
  );

  return blockHeight;
}
