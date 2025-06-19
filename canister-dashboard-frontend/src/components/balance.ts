import { LedgerApi } from '../api/ledger';
import { topUp } from '../top-up';

class BalanceManager {
  async init(): Promise<void> {
    const balanceSection = document.getElementById('balance-section');

    balanceSection!.innerHTML = `
            <h3>Top up</h3>
            <div id="balance-content">Loading...</div>
        `;

    const balanceContent = document.getElementById('balance-content');

    const ledgerApi = new LedgerApi();
    const balance = await ledgerApi.balance();

    balanceContent!.innerHTML = `
            <p><strong>Balance:</strong> ${(Number(balance) / 100000000).toFixed(8)} ICP</p>
            <p><button id="top-up-btn" class="btn">Top-up</button></p>
        `;

    // Add event listener for top-up button
    const topUpBtn = document.getElementById('top-up-btn');
    if (topUpBtn) {
      topUpBtn.addEventListener('click', () => {
        topUp();
      });
    }
  }
}

export async function initBalance(): Promise<void> {
  const balanceManager = new BalanceManager();
  await balanceManager.init();
}
