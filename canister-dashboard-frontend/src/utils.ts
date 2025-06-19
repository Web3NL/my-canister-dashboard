import { Principal } from '@dfinity/principal';
import { HttpAgent } from '@dfinity/agent';
import { host } from './config';
import { AuthClient } from '@dfinity/auth-client';

export function inferCanisterIdFromLocation(): Principal {
  const hostname = window.location.hostname;

  // Pattern for localhost: u6s2n-gx777-77774-qaaba-cai.localhost
  const localhostMatch = hostname.match(/^([a-z0-9-]+)\.localhost$/);
  if (localhostMatch) {
    return Principal.fromText(localhostMatch[1]);
  }

  // Pattern for IC: u6s2n-gx777-77774-qaaba-cai.icp0.io
  const icMatch = hostname.match(/^([a-z0-9-]+)\.icp\d+\.io$/);
  if (icMatch) {
    return Principal.fromText(icMatch[1]);
  }

  throw new Error('Could not infer canister ID from location');
}

export async function createHttpAgent(): Promise<HttpAgent> {
  const authClient = await AuthClient.create();
  const isAuthed = await authClient.isAuthenticated();
  if (!isAuthed) {
    window.location.reload();
  }

  const identity = authClient.getIdentity();
  const agent = await HttpAgent.create({
    identity,
    host,
  });

  // Fetch root key for local development
  if (host.includes('localhost')) {
    await agent.fetchRootKey();
  }

  return agent;
}

export function convertMemoToBigInt(memo: Uint8Array): bigint {
  let result = BigInt(0);
  for (let i = 0; i < memo.length; i++) {
    result = (result << BigInt(8)) | BigInt(memo[i]);
  }
  return result;
}

export function principalToSubaccount(principal: Principal): Uint8Array {
  const principalBytes = principal.toUint8Array();
  const subaccount = new Uint8Array(32);

  // First byte is the length of the principal
  subaccount[0] = principalBytes.length;

  // Principal bytes are copied starting from byte 1
  subaccount.set(principalBytes, 1);

  return subaccount;
}

export function formatMemorySize(bytes: bigint): string {
  const mb = Number(bytes) / (1024 * 1024);
  return `${mb.toFixed(2)} MB`;
}

export function formatCycles(cycles: bigint): string {
  const trillion = Number(cycles) / 1e12;
  return `${trillion.toFixed(2)} T`;
}
