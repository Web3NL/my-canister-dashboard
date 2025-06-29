// Configuration loaded from environment variables

export const identityProvider =
  import.meta.env.VITE_IDENTITY_PROVIDER ||
  'https://identity.internetcomputer.org';

export const host = import.meta.env.VITE_HOSTNAME || 'https://icp0.io';

// Timer configuration
export const PAGE_REFRESH_INTERVAL = 5 * 60 * 1000; // 5 minutes in milliseconds

// Canister IDs
export const CMC_CANISTER_ID = 'rkp4c-7iaaa-aaaaa-aaaca-cai';

// Transaction fees
export const ICP_TX_FEE = BigInt(10000); // 0.0001 ICP in e8s

// TPUP memo for CMC top-up (first 4 bytes spell "TPUP" in ASCII)
export const TPUP_MEMO = new Uint8Array([
  0x54, 0x50, 0x55, 0x50, 0x00, 0x00, 0x00, 0x00,
]);
