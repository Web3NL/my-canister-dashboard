import { AuthClient } from '@dfinity/auth-client';
import { identityProvider } from '../config';

class AuthManager {
  private authClient: AuthClient | null = null;

  async init(): Promise<void> {
    this.authClient = await AuthClient.create();
    this.renderAuthSection();

    const isAuthed = await this.authClient.isAuthenticated();

    if (isAuthed) {
      const principalText = this.authClient
        .getIdentity()
        .getPrincipal()
        .toText();
      this.setLoggedInState(principalText);
    } else {
      this.setLoggedOutState();
    }
  }

  private renderAuthSection() {
    const authSection = document.getElementById('auth-section');

    authSection!.innerHTML = `
            <div class="auth-section">
                <button id="auth-btn" class="btn"></button>
                <div id="ii-principal" class="principal hidden"></div>
            </div>
        `;
  }

  private setLoggedInState(principalText: string): void {
    document.getElementById('auth-btn')!.textContent = 'Logout';
    document.getElementById('auth-btn')!.onclick = () => this.handleLogout();

    document.getElementById('ii-principal')!.classList.remove('hidden');
    document.getElementById('ii-principal')!.textContent = principalText;

    document
      .getElementById('authenticated-content')!
      .classList.remove('hidden');
  }

  private setLoggedOutState(): void {
    document.getElementById('auth-btn')!.textContent = 'Login';
    document.getElementById('auth-btn')!.onclick = () => this.handleLogin();

    document.getElementById('ii-principal')!.classList.add('hidden');
    document.getElementById('ii-principal')!.textContent = '';

    document.getElementById('authenticated-content')!.classList.add('hidden');
  }

  private async handleLogin(): Promise<void> {
    const isAuthed = await this.authClient!.isAuthenticated();

    if (isAuthed) {
      window.location.reload();
    }

    this.authClient!.login({
      identityProvider,
      onSuccess: () => {
        window.location.reload();
      },
      onError: () => {
        window.location.reload();
      },
    });
  }

  private async handleLogout(): Promise<void> {
    await this.authClient!.logout();
    window.location.reload();
  }
}

export async function initAuth(): Promise<void> {
  const authManager = new AuthManager();
  await authManager.init();
}
