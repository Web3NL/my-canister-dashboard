import { LedgerApi } from '../api/ledger';
import { topUp } from '../top-up';

class BalanceManager {
  async init(): Promise<void> {
    this.renderBalanceSection();

    const ledgerApi = new LedgerApi();
    const balance = await ledgerApi.balance();
    const formattedBalance = (Number(balance) / 100000000).toFixed(8);

    this.renderBalanceContent(formattedBalance);
    this.attachEventListeners();
  }

  private renderBalanceSection(): void {
    const balanceSection = document.getElementById('balance-section');

    balanceSection!.innerHTML = `
            <h3>Top up</h3>
            <div id="balance-content">Loading...</div>
        `;
  }

  private renderBalanceContent(formattedBalance: string): void {
    const balanceContent = document.getElementById('balance-content');

    balanceContent!.innerHTML = `
            <p><strong>Balance:</strong> ${formattedBalance} ICP</p>
            <p><button id="top-up-btn" class="btn">Top-up</button></p>
        `;
  }

  private attachEventListeners(): void {
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
