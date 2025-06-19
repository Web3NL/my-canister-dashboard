import { PAGE_REFRESH_INTERVAL } from './config';
import { initAuth } from './components/auth';
import { initStatus } from './components/status';
import { AuthClient } from '@dfinity/auth-client';
import { initBalance } from './components/balance';
import { initControllers } from './components/controllers';
import { initAlternativeOrigins } from './components/alternativeOrigins';

class Dashboard {
  constructor() {
    this.init();
  }

  async init(): Promise<void> {
    await initAuth();

    const authClient = await AuthClient.create();
    const isAuthed = await authClient.isAuthenticated();

    if (isAuthed) {
      await Promise.all([
        initStatus(),
        initBalance(),
        initControllers(),
        initAlternativeOrigins(),
      ]);
    }

    this.startRefreshTimer();
  }

  private startRefreshTimer(): void {
    setInterval(() => {
      window.location.reload();
    }, PAGE_REFRESH_INTERVAL);
  }
}

// Initialize the dashboard when the page loads
document.addEventListener('DOMContentLoaded', () => {
  new Dashboard();
});
