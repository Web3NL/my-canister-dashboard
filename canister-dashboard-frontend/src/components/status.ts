import { ManagementApi } from '../api/management';
import { uint8ArrayToHexString } from '@dfinity/utils';
import { formatMemorySize, formatCycles } from '../utils';

class StatusManager {
  async init(): Promise<void> {
    const statusSection = document.getElementById('status-section');

    statusSection!.innerHTML = `
            <h3>Canister Status</h3>
            <div id="status-content">Loading...</div>
        `;

    const statusContent = document.getElementById('status-content');

    const managementApi = new ManagementApi();
    const status = await managementApi.getCanisterStatus();

    const statusText =
      'running' in status.status
        ? 'Running'
        : 'stopped' in status.status
          ? 'Stopped'
          : 'stopping' in status.status
            ? 'Stopping'
            : 'Unknown';
    const memorySizeFormatted = formatMemorySize(status.memory_size);
    const cyclesFormatted = formatCycles(status.cycles);
    const moduleHashHex =
      status.module_hash && status.module_hash.length > 0
        ? uint8ArrayToHexString(status.module_hash[0] as Uint8Array)
        : 'N/A';

    statusContent!.innerHTML = `
                <div class="status-info">
                    <p><strong>Status:</strong> ${statusText}</p>
                    <p><strong>Memory Size:</strong> ${memorySizeFormatted}</p>
                    <p><strong>Cycles:</strong> ${cyclesFormatted}</p>
                    <p><strong>Module Hash:</strong> ${moduleHashHex}</p>
                </div>
            `;
  }
}

export async function initStatus(): Promise<void> {
  const statusManager = new StatusManager();
  await statusManager.init();
}
