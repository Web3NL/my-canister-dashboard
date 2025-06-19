import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface HttpRequest {
  'url' : string,
  'method' : string,
  'body' : Uint8Array | number[],
  'headers' : Array<[string, string]>,
}
export interface HttpResponse {
  'body' : Uint8Array | number[],
  'headers' : Array<[string, string]>,
  'status_code' : number,
}
export type UpdateAlternativeOriginsArg = {
    'RemoveAlternativeOrigin' : string
  } |
  { 'AddAlternativeOrigin' : string };
export type UpdateAlternativeOriginsResult = { 'Ok' : null } |
  { 'Err' : string };
export interface _SERVICE {
  'http_request' : ActorMethod<[HttpRequest], HttpResponse>,
  'update_alternative_origins' : ActorMethod<
    [UpdateAlternativeOriginsArg],
    UpdateAlternativeOriginsResult
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
