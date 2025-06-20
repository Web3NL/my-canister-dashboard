import { ManagementApi } from '../api/management';

class ControllersManager {
  async init(): Promise<void> {
    this.renderControllersSection();

    const managementApi = new ManagementApi();
    const status = await managementApi.getCanisterStatus();

    const controllersList = status.settings.controllers
      .map(controller => `<li class="principal">${controller.toString()}</li>`)
      .join('');

    this.renderControllersContent(controllersList);
  }

  private renderControllersSection(): void {
    const controllersSection = document.getElementById('controllers-section');

    controllersSection!.innerHTML = `
            <h3>Controllers</h3>
            <div id="controllers-content">Loading...</div>
        `;
  }

  private renderControllersContent(controllersList: string): void {
    const controllersContent = document.getElementById('controllers-content');

    controllersContent!.innerHTML = `
                <div class="controllers-info">
                    <ul>
                        ${controllersList}
                    </ul>
                </div>
            `;
  }
}

export async function initControllers(): Promise<void> {
  const controllersManager = new ControllersManager();
  await controllersManager.init();
}
