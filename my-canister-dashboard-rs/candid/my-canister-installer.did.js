export const idlFactory = ({ IDL }) => {
  const WasmStatus = IDL.Record({
    'memo' : IDL.Opt(IDL.Text),
    'name' : IDL.Text,
    'version' : IDL.Nat16,
  });
  const HttpRequest = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(IDL.Tuple(IDL.Text, IDL.Text)),
  });
  const HttpResponse = IDL.Record({
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(IDL.Tuple(IDL.Text, IDL.Text)),
    'status_code' : IDL.Nat16,
  });
  const UpdateAlternativeOriginsArg = IDL.Variant({
    'RemoveAlternativeOrigin' : IDL.Text,
    'AddAlternativeOrigin' : IDL.Text,
  });
  const UpdateAlternativeOriginsResult = IDL.Variant({
    'Ok' : IDL.Null,
    'Err' : IDL.Text,
  });
  const UpdateIIPrincipal = IDL.Variant({
    'Get' : IDL.Null,
    'Set' : IDL.Principal,
  });
  const UpdateIIPrincipalResult = IDL.Variant({
    'Ok' : IDL.Opt(IDL.Principal),
    'Err' : IDL.Text,
  });
  return IDL.Service({
    'get_wasm_status' : IDL.Func([], [WasmStatus], ['query']),
    'http_request' : IDL.Func([HttpRequest], [HttpResponse], ['query']),
    'update_alternative_origins' : IDL.Func(
        [UpdateAlternativeOriginsArg],
        [UpdateAlternativeOriginsResult],
        [],
      ),
    'update_ii_principal' : IDL.Func(
        [UpdateIIPrincipal],
        [UpdateIIPrincipalResult],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
