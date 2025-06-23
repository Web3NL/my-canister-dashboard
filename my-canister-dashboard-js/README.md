# @web3nl/my-canister-dashboard

Utility functions for canisters using My Canister Dashboard on the Internet Computer.

## Installation

```bash
npm install @web3nl/my-canister-dashboard
```

## Usage

### Basic Setup

```typescript
import { MyCanisterDashboard } from '@web3nl/my-canister-dashboard';
import { HttpAgent } from '@dfinity/agent';
import { Principal } from '@dfinity/principal';

// Create an HTTP agent
const agent = await HttpAgent.create({ host: 'https://icp0.io' });

// Create dashboard instance for your canister
const canisterId = Principal.fromText('your-canister-id');
const dashboard = MyCanisterDashboard.create(agent, canisterId);
```

### Check Cycles Balance

```typescript
// Basic cycles check
const result = await dashboard.checkCyclesBalance();

if ('ok' in result) {
  console.log(`Cycles: ${result.ok}`);
} else {
  console.error(`Error: ${result.error}`);
}
```

### Custom Threshold

```typescript
import { LOW_CYCLES_THRESHOLD } from '@web3nl/my-canister-dashboard';

// Use custom threshold
const result = await dashboard.checkCyclesBalance({
  threshold: 500_000_000_000n // 500 billion cycles
});

// Default threshold is 1 trillion cycles
console.log(`Default threshold: ${LOW_CYCLES_THRESHOLD}`);
```

### Error Handling

```typescript
const result = await dashboard.checkCyclesBalance();

if ('error' in result) {
  if (result.error.includes('Low cycles warning')) {
    // Cycles are below threshold
    console.warn('⚠️ Cycles are running low!');
  } else {
    // API or network error
    console.error('❌ Failed to check cycles:', result.error);
  }
} else {
  // Success - cycles are above threshold
  console.log(`✅ Cycles OK: ${result.ok}`);
}
```

## API Reference

### `MyCanisterDashboard`

Main class for canister management utilities.

#### `MyCanisterDashboard.create(agent, canisterId)`

Creates a new dashboard instance.

- **agent**: `HttpAgent` - Authenticated HTTP agent for IC communication
- **canisterId**: `Principal` - The canister ID to monitor
- **Returns**: `MyCanisterDashboard` - New dashboard instance

#### `checkCyclesBalance(options?)`

Checks the cycles balance of the canister.

- **options**: `CheckCyclesBalanceOptions` (optional)
  - **threshold**: `bigint` - Custom threshold for low cycles warning
- **Returns**: `Promise<CheckCyclesBalanceResult>`

#### `CheckCyclesBalanceResult`

Discriminated union type for cycles check results:

```typescript
type CheckCyclesBalanceResult = 
  | { ok: bigint }      // Success: current cycles balance
  | { error: string }   // Error: API error or low cycles warning
```

### Constants

#### `LOW_CYCLES_THRESHOLD`

Default threshold for low cycles warnings: `1_000_000_000_000n` (1 trillion cycles)

## Development

```bash
# Install dependencies
npm install

# Build the package
npm run build

# Watch mode during development
npm run dev

# Lint and format
npm run lint
npm run format

# Type checking
npm run typecheck

# Run all checks
npm run check

# Auto-fix issues and run checks
npm run check:fix
```

## Requirements

- Node.js >= 18.0.0
- TypeScript support for best experience

## License

MIT