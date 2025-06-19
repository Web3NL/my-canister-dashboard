import { ManagementApi } from '../api/management';

class ControllersManager {
  async init(): Promise<void> {
    const controllersSection = document.getElementById('controllers-section');

    controllersSection!.innerHTML = `
            <h3>Controllers</h3>
            <div id="controllers-content">Loading...</div>
        `;

    const controllersContent = document.getElementById('controllers-content');

    const managementApi = new ManagementApi();
    const status = await managementApi.getCanisterStatus();

    const controllersList = status.settings.controllers
      .map(controller => `<li class="principal">${controller.toString()}</li>`)
      .join('');

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
