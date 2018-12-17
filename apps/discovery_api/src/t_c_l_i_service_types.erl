%%
%% Autogenerated by Thrift Compiler (0.11.0)
%%
%% DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
%%

-module(t_c_l_i_service_types).

-include("t_c_l_i_service_types.hrl").

-export([struct_info/1, struct_info_ext/1, enum_info/1, enum_names/0, struct_names/0, exception_names/0]).

struct_info('TTypeQualifierValue') ->
  {struct, [{1, i32},
          {2, string}]}
;

struct_info('TTypeQualifiers') ->
  {struct, [{1, {map, string, {struct, {'t_c_l_i_service_types', 'TTypeQualifierValue'}}}}]}
;

struct_info('TPrimitiveTypeEntry') ->
  {struct, [{1, i32},
          {2, {struct, {'t_c_l_i_service_types', 'TTypeQualifiers'}}}]}
;

struct_info('TArrayTypeEntry') ->
  {struct, [{1, i32}]}
;

struct_info('TMapTypeEntry') ->
  {struct, [{1, i32},
          {2, i32}]}
;

struct_info('TStructTypeEntry') ->
  {struct, [{1, {map, string, i32}}]}
;

struct_info('TUnionTypeEntry') ->
  {struct, [{1, {map, string, i32}}]}
;

struct_info('TUserDefinedTypeEntry') ->
  {struct, [{1, string}]}
;

struct_info('TTypeEntry') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TPrimitiveTypeEntry'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TArrayTypeEntry'}}},
          {3, {struct, {'t_c_l_i_service_types', 'TMapTypeEntry'}}},
          {4, {struct, {'t_c_l_i_service_types', 'TStructTypeEntry'}}},
          {5, {struct, {'t_c_l_i_service_types', 'TUnionTypeEntry'}}},
          {6, {struct, {'t_c_l_i_service_types', 'TUserDefinedTypeEntry'}}}]}
;

struct_info('TTypeDesc') ->
  {struct, [{1, {list, {struct, {'t_c_l_i_service_types', 'TTypeEntry'}}}}]}
;

struct_info('TColumnDesc') ->
  {struct, [{1, string},
          {2, {struct, {'t_c_l_i_service_types', 'TTypeDesc'}}},
          {3, i32},
          {4, string}]}
;

struct_info('TTableSchema') ->
  {struct, [{1, {list, {struct, {'t_c_l_i_service_types', 'TColumnDesc'}}}}]}
;

struct_info('TBoolValue') ->
  {struct, [{1, bool}]}
;

struct_info('TByteValue') ->
  {struct, [{1, byte}]}
;

struct_info('TI16Value') ->
  {struct, [{1, i16}]}
;

struct_info('TI32Value') ->
  {struct, [{1, i32}]}
;

struct_info('TI64Value') ->
  {struct, [{1, i64}]}
;

struct_info('TDoubleValue') ->
  {struct, [{1, double}]}
;

struct_info('TStringValue') ->
  {struct, [{1, string}]}
;

struct_info('TColumnValue') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TBoolValue'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TByteValue'}}},
          {3, {struct, {'t_c_l_i_service_types', 'TI16Value'}}},
          {4, {struct, {'t_c_l_i_service_types', 'TI32Value'}}},
          {5, {struct, {'t_c_l_i_service_types', 'TI64Value'}}},
          {6, {struct, {'t_c_l_i_service_types', 'TDoubleValue'}}},
          {7, {struct, {'t_c_l_i_service_types', 'TStringValue'}}}]}
;

struct_info('TRow') ->
  {struct, [{1, {list, {struct, {'t_c_l_i_service_types', 'TColumnValue'}}}}]}
;

struct_info('TBoolColumn') ->
  {struct, [{1, {list, bool}},
          {2, string}]}
;

struct_info('TByteColumn') ->
  {struct, [{1, {list, byte}},
          {2, string}]}
;

struct_info('TI16Column') ->
  {struct, [{1, {list, i16}},
          {2, string}]}
;

struct_info('TI32Column') ->
  {struct, [{1, {list, i32}},
          {2, string}]}
;

struct_info('TI64Column') ->
  {struct, [{1, {list, i64}},
          {2, string}]}
;

struct_info('TDoubleColumn') ->
  {struct, [{1, {list, double}},
          {2, string}]}
;

struct_info('TStringColumn') ->
  {struct, [{1, {list, string}},
          {2, string}]}
;

struct_info('TBinaryColumn') ->
  {struct, [{1, {list, string}},
          {2, string}]}
;

struct_info('TColumn') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TBoolColumn'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TByteColumn'}}},
          {3, {struct, {'t_c_l_i_service_types', 'TI16Column'}}},
          {4, {struct, {'t_c_l_i_service_types', 'TI32Column'}}},
          {5, {struct, {'t_c_l_i_service_types', 'TI64Column'}}},
          {6, {struct, {'t_c_l_i_service_types', 'TDoubleColumn'}}},
          {7, {struct, {'t_c_l_i_service_types', 'TStringColumn'}}},
          {8, {struct, {'t_c_l_i_service_types', 'TBinaryColumn'}}}]}
;

struct_info('TRowSet') ->
  {struct, [{1, i64},
          {2, {list, {struct, {'t_c_l_i_service_types', 'TRow'}}}},
          {3, {list, {struct, {'t_c_l_i_service_types', 'TColumn'}}}}]}
;

struct_info('TStatus') ->
  {struct, [{1, i32},
          {2, {list, string}},
          {3, string},
          {4, i32},
          {5, string}]}
;

struct_info('THandleIdentifier') ->
  {struct, [{1, string},
          {2, string}]}
;

struct_info('TSessionHandle') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'THandleIdentifier'}}}]}
;

struct_info('TOperationHandle') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'THandleIdentifier'}}},
          {2, i32},
          {3, bool},
          {4, double}]}
;

struct_info('TOpenSessionReq') ->
  {struct, [{1, i32},
          {2, string},
          {3, string},
          {4, {map, string, string}}]}
;

struct_info('TOpenSessionResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, i32},
          {3, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}},
          {4, {map, string, string}}]}
;

struct_info('TCloseSessionReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}}]}
;

struct_info('TCloseSessionResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}}]}
;

struct_info('TGetInfoValue') ->
  {struct, [{1, string},
          {2, i16},
          {3, i32},
          {4, i32},
          {5, i32},
          {6, i64}]}
;

struct_info('TGetInfoReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}},
          {2, i32}]}
;

struct_info('TGetInfoResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TGetInfoValue'}}}]}
;

struct_info('TExecuteStatementReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}},
          {2, string},
          {3, {map, string, string}},
          {4, bool}]}
;

struct_info('TExecuteStatementResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}}]}
;

struct_info('TGetTypeInfoReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}}]}
;

struct_info('TGetTypeInfoResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}}]}
;

struct_info('TGetCatalogsReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}}]}
;

struct_info('TGetCatalogsResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}}]}
;

struct_info('TGetSchemasReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}},
          {2, string},
          {3, string}]}
;

struct_info('TGetSchemasResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}}]}
;

struct_info('TGetTablesReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}},
          {2, string},
          {3, string},
          {4, string},
          {5, {list, string}}]}
;

struct_info('TGetTablesResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}}]}
;

struct_info('TGetTableTypesReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}}]}
;

struct_info('TGetTableTypesResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}}]}
;

struct_info('TGetColumnsReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}},
          {2, string},
          {3, string},
          {4, string},
          {5, string}]}
;

struct_info('TGetColumnsResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}}]}
;

struct_info('TGetFunctionsReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}},
          {2, string},
          {3, string},
          {4, string}]}
;

struct_info('TGetFunctionsResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}}]}
;

struct_info('TGetOperationStatusReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}}]}
;

struct_info('TGetOperationStatusResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, i32},
          {3, string},
          {4, i32},
          {5, string}]}
;

struct_info('TCancelOperationReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}}]}
;

struct_info('TCancelOperationResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}}]}
;

struct_info('TCloseOperationReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}}]}
;

struct_info('TCloseOperationResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}}]}
;

struct_info('TGetResultSetMetadataReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}}]}
;

struct_info('TGetResultSetMetadataResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, {struct, {'t_c_l_i_service_types', 'TTableSchema'}}}]}
;

struct_info('TFetchResultsReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}},
          {2, i32},
          {3, i64},
          {4, i16}]}
;

struct_info('TFetchResultsResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, bool},
          {3, {struct, {'t_c_l_i_service_types', 'TRowSet'}}}]}
;

struct_info('TGetDelegationTokenReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}},
          {2, string},
          {3, string}]}
;

struct_info('TGetDelegationTokenResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}},
          {2, string}]}
;

struct_info('TCancelDelegationTokenReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}},
          {2, string}]}
;

struct_info('TCancelDelegationTokenResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}}]}
;

struct_info('TRenewDelegationTokenReq') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}},
          {2, string}]}
;

struct_info('TRenewDelegationTokenResp') ->
  {struct, [{1, {struct, {'t_c_l_i_service_types', 'TStatus'}}}]}
;

struct_info(_) -> erlang:error(function_clause).

struct_info_ext('TTypeQualifierValue') ->
  {struct, [{1, optional, i32, 'i32Value', undefined},
          {2, optional, string, 'stringValue', undefined}]}
;

struct_info_ext('TTypeQualifiers') ->
  {struct, [{1, required, {map, string, {struct, {'t_c_l_i_service_types', 'TTypeQualifierValue'}}}, 'qualifiers', dict:new()}]}
;

struct_info_ext('TPrimitiveTypeEntry') ->
  {struct, [{1, required, i32, 'type', undefined},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TTypeQualifiers'}}, 'typeQualifiers', #'TTypeQualifiers'{}}]}
;

struct_info_ext('TArrayTypeEntry') ->
  {struct, [{1, required, i32, 'objectTypePtr', undefined}]}
;

struct_info_ext('TMapTypeEntry') ->
  {struct, [{1, required, i32, 'keyTypePtr', undefined},
          {2, required, i32, 'valueTypePtr', undefined}]}
;

struct_info_ext('TStructTypeEntry') ->
  {struct, [{1, required, {map, string, i32}, 'nameToTypePtr', dict:new()}]}
;

struct_info_ext('TUnionTypeEntry') ->
  {struct, [{1, required, {map, string, i32}, 'nameToTypePtr', dict:new()}]}
;

struct_info_ext('TUserDefinedTypeEntry') ->
  {struct, [{1, required, string, 'typeClassName', undefined}]}
;

struct_info_ext('TTypeEntry') ->
  {struct, [{1, optional, {struct, {'t_c_l_i_service_types', 'TPrimitiveTypeEntry'}}, 'primitiveEntry', #'TPrimitiveTypeEntry'{}},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TArrayTypeEntry'}}, 'arrayEntry', #'TArrayTypeEntry'{}},
          {3, optional, {struct, {'t_c_l_i_service_types', 'TMapTypeEntry'}}, 'mapEntry', #'TMapTypeEntry'{}},
          {4, optional, {struct, {'t_c_l_i_service_types', 'TStructTypeEntry'}}, 'structEntry', #'TStructTypeEntry'{}},
          {5, optional, {struct, {'t_c_l_i_service_types', 'TUnionTypeEntry'}}, 'unionEntry', #'TUnionTypeEntry'{}},
          {6, optional, {struct, {'t_c_l_i_service_types', 'TUserDefinedTypeEntry'}}, 'userDefinedTypeEntry', #'TUserDefinedTypeEntry'{}}]}
;

struct_info_ext('TTypeDesc') ->
  {struct, [{1, required, {list, {struct, {'t_c_l_i_service_types', 'TTypeEntry'}}}, 'types', []}]}
;

struct_info_ext('TColumnDesc') ->
  {struct, [{1, required, string, 'columnName', undefined},
          {2, required, {struct, {'t_c_l_i_service_types', 'TTypeDesc'}}, 'typeDesc', #'TTypeDesc'{}},
          {3, required, i32, 'position', undefined},
          {4, optional, string, 'comment', undefined}]}
;

struct_info_ext('TTableSchema') ->
  {struct, [{1, required, {list, {struct, {'t_c_l_i_service_types', 'TColumnDesc'}}}, 'columns', []}]}
;

struct_info_ext('TBoolValue') ->
  {struct, [{1, optional, bool, 'value', undefined}]}
;

struct_info_ext('TByteValue') ->
  {struct, [{1, optional, byte, 'value', undefined}]}
;

struct_info_ext('TI16Value') ->
  {struct, [{1, optional, i16, 'value', undefined}]}
;

struct_info_ext('TI32Value') ->
  {struct, [{1, optional, i32, 'value', undefined}]}
;

struct_info_ext('TI64Value') ->
  {struct, [{1, optional, i64, 'value', undefined}]}
;

struct_info_ext('TDoubleValue') ->
  {struct, [{1, optional, double, 'value', undefined}]}
;

struct_info_ext('TStringValue') ->
  {struct, [{1, optional, string, 'value', undefined}]}
;

struct_info_ext('TColumnValue') ->
  {struct, [{1, optional, {struct, {'t_c_l_i_service_types', 'TBoolValue'}}, 'boolVal', #'TBoolValue'{}},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TByteValue'}}, 'byteVal', #'TByteValue'{}},
          {3, optional, {struct, {'t_c_l_i_service_types', 'TI16Value'}}, 'i16Val', #'TI16Value'{}},
          {4, optional, {struct, {'t_c_l_i_service_types', 'TI32Value'}}, 'i32Val', #'TI32Value'{}},
          {5, optional, {struct, {'t_c_l_i_service_types', 'TI64Value'}}, 'i64Val', #'TI64Value'{}},
          {6, optional, {struct, {'t_c_l_i_service_types', 'TDoubleValue'}}, 'doubleVal', #'TDoubleValue'{}},
          {7, optional, {struct, {'t_c_l_i_service_types', 'TStringValue'}}, 'stringVal', #'TStringValue'{}}]}
;

struct_info_ext('TRow') ->
  {struct, [{1, required, {list, {struct, {'t_c_l_i_service_types', 'TColumnValue'}}}, 'colVals', []}]}
;

struct_info_ext('TBoolColumn') ->
  {struct, [{1, required, {list, bool}, 'values', []},
          {2, required, string, 'nulls', undefined}]}
;

struct_info_ext('TByteColumn') ->
  {struct, [{1, required, {list, byte}, 'values', []},
          {2, required, string, 'nulls', undefined}]}
;

struct_info_ext('TI16Column') ->
  {struct, [{1, required, {list, i16}, 'values', []},
          {2, required, string, 'nulls', undefined}]}
;

struct_info_ext('TI32Column') ->
  {struct, [{1, required, {list, i32}, 'values', []},
          {2, required, string, 'nulls', undefined}]}
;

struct_info_ext('TI64Column') ->
  {struct, [{1, required, {list, i64}, 'values', []},
          {2, required, string, 'nulls', undefined}]}
;

struct_info_ext('TDoubleColumn') ->
  {struct, [{1, required, {list, double}, 'values', []},
          {2, required, string, 'nulls', undefined}]}
;

struct_info_ext('TStringColumn') ->
  {struct, [{1, required, {list, string}, 'values', []},
          {2, required, string, 'nulls', undefined}]}
;

struct_info_ext('TBinaryColumn') ->
  {struct, [{1, required, {list, string}, 'values', []},
          {2, required, string, 'nulls', undefined}]}
;

struct_info_ext('TColumn') ->
  {struct, [{1, optional, {struct, {'t_c_l_i_service_types', 'TBoolColumn'}}, 'boolVal', #'TBoolColumn'{}},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TByteColumn'}}, 'byteVal', #'TByteColumn'{}},
          {3, optional, {struct, {'t_c_l_i_service_types', 'TI16Column'}}, 'i16Val', #'TI16Column'{}},
          {4, optional, {struct, {'t_c_l_i_service_types', 'TI32Column'}}, 'i32Val', #'TI32Column'{}},
          {5, optional, {struct, {'t_c_l_i_service_types', 'TI64Column'}}, 'i64Val', #'TI64Column'{}},
          {6, optional, {struct, {'t_c_l_i_service_types', 'TDoubleColumn'}}, 'doubleVal', #'TDoubleColumn'{}},
          {7, optional, {struct, {'t_c_l_i_service_types', 'TStringColumn'}}, 'stringVal', #'TStringColumn'{}},
          {8, optional, {struct, {'t_c_l_i_service_types', 'TBinaryColumn'}}, 'binaryVal', #'TBinaryColumn'{}}]}
;

struct_info_ext('TRowSet') ->
  {struct, [{1, required, i64, 'startRowOffset', undefined},
          {2, required, {list, {struct, {'t_c_l_i_service_types', 'TRow'}}}, 'rows', []},
          {3, optional, {list, {struct, {'t_c_l_i_service_types', 'TColumn'}}}, 'columns', []}]}
;

struct_info_ext('TStatus') ->
  {struct, [{1, required, i32, 'statusCode', undefined},
          {2, optional, {list, string}, 'infoMessages', []},
          {3, optional, string, 'sqlState', undefined},
          {4, optional, i32, 'errorCode', undefined},
          {5, optional, string, 'errorMessage', undefined}]}
;

struct_info_ext('THandleIdentifier') ->
  {struct, [{1, required, string, 'guid', undefined},
          {2, required, string, 'secret', undefined}]}
;

struct_info_ext('TSessionHandle') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'THandleIdentifier'}}, 'sessionId', #'THandleIdentifier'{}}]}
;

struct_info_ext('TOperationHandle') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'THandleIdentifier'}}, 'operationId', #'THandleIdentifier'{}},
          {2, required, i32, 'operationType', undefined},
          {3, required, bool, 'hasResultSet', undefined},
          {4, optional, double, 'modifiedRowCount', undefined}]}
;

struct_info_ext('TOpenSessionReq') ->
  {struct, [{1, required, i32, 'client_protocol',   7},
          {2, optional, string, 'username', undefined},
          {3, optional, string, 'password', undefined},
          {4, optional, {map, string, string}, 'configuration', dict:new()}]}
;

struct_info_ext('TOpenSessionResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, required, i32, 'serverProtocolVersion',   7},
          {3, optional, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}},
          {4, optional, {map, string, string}, 'configuration', dict:new()}]}
;

struct_info_ext('TCloseSessionReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}}]}
;

struct_info_ext('TCloseSessionResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}}]}
;

struct_info_ext('TGetInfoValue') ->
  {struct, [{1, optional, string, 'stringValue', undefined},
          {2, optional, i16, 'smallIntValue', undefined},
          {3, optional, i32, 'integerBitmask', undefined},
          {4, optional, i32, 'integerFlag', undefined},
          {5, optional, i32, 'binaryValue', undefined},
          {6, optional, i64, 'lenValue', undefined}]}
;

struct_info_ext('TGetInfoReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}},
          {2, required, i32, 'infoType', undefined}]}
;

struct_info_ext('TGetInfoResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, required, {struct, {'t_c_l_i_service_types', 'TGetInfoValue'}}, 'infoValue', #'TGetInfoValue'{}}]}
;

struct_info_ext('TExecuteStatementReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}},
          {2, required, string, 'statement', undefined},
          {3, optional, {map, string, string}, 'confOverlay', dict:new()},
          {4, optional, bool, 'runAsync', false}]}
;

struct_info_ext('TExecuteStatementResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}}]}
;

struct_info_ext('TGetTypeInfoReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}}]}
;

struct_info_ext('TGetTypeInfoResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}}]}
;

struct_info_ext('TGetCatalogsReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}}]}
;

struct_info_ext('TGetCatalogsResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}}]}
;

struct_info_ext('TGetSchemasReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}},
          {2, optional, string, 'catalogName', undefined},
          {3, optional, string, 'schemaName', undefined}]}
;

struct_info_ext('TGetSchemasResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}}]}
;

struct_info_ext('TGetTablesReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}},
          {2, optional, string, 'catalogName', undefined},
          {3, optional, string, 'schemaName', undefined},
          {4, optional, string, 'tableName', undefined},
          {5, optional, {list, string}, 'tableTypes', []}]}
;

struct_info_ext('TGetTablesResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}}]}
;

struct_info_ext('TGetTableTypesReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}}]}
;

struct_info_ext('TGetTableTypesResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}}]}
;

struct_info_ext('TGetColumnsReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}},
          {2, optional, string, 'catalogName', undefined},
          {3, optional, string, 'schemaName', undefined},
          {4, optional, string, 'tableName', undefined},
          {5, optional, string, 'columnName', undefined}]}
;

struct_info_ext('TGetColumnsResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}}]}
;

struct_info_ext('TGetFunctionsReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}},
          {2, optional, string, 'catalogName', undefined},
          {3, optional, string, 'schemaName', undefined},
          {4, required, string, 'functionName', undefined}]}
;

struct_info_ext('TGetFunctionsResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}}]}
;

struct_info_ext('TGetOperationStatusReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}}]}
;

struct_info_ext('TGetOperationStatusResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, optional, i32, 'operationState', undefined},
          {3, optional, string, 'sqlState', undefined},
          {4, optional, i32, 'errorCode', undefined},
          {5, optional, string, 'errorMessage', undefined}]}
;

struct_info_ext('TCancelOperationReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}}]}
;

struct_info_ext('TCancelOperationResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}}]}
;

struct_info_ext('TCloseOperationReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}}]}
;

struct_info_ext('TCloseOperationResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}}]}
;

struct_info_ext('TGetResultSetMetadataReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}}]}
;

struct_info_ext('TGetResultSetMetadataResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, optional, {struct, {'t_c_l_i_service_types', 'TTableSchema'}}, 'schema', #'TTableSchema'{}}]}
;

struct_info_ext('TFetchResultsReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TOperationHandle'}}, 'operationHandle', #'TOperationHandle'{}},
          {2, required, i32, 'orientation',   0},
          {3, required, i64, 'maxRows', undefined},
          {4, optional, i16, 'fetchType', 0}]}
;

struct_info_ext('TFetchResultsResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, optional, bool, 'hasMoreRows', undefined},
          {3, optional, {struct, {'t_c_l_i_service_types', 'TRowSet'}}, 'results', #'TRowSet'{}}]}
;

struct_info_ext('TGetDelegationTokenReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}},
          {2, required, string, 'owner', undefined},
          {3, required, string, 'renewer', undefined}]}
;

struct_info_ext('TGetDelegationTokenResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}},
          {2, optional, string, 'delegationToken', undefined}]}
;

struct_info_ext('TCancelDelegationTokenReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}},
          {2, required, string, 'delegationToken', undefined}]}
;

struct_info_ext('TCancelDelegationTokenResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}}]}
;

struct_info_ext('TRenewDelegationTokenReq') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TSessionHandle'}}, 'sessionHandle', #'TSessionHandle'{}},
          {2, required, string, 'delegationToken', undefined}]}
;

struct_info_ext('TRenewDelegationTokenResp') ->
  {struct, [{1, required, {struct, {'t_c_l_i_service_types', 'TStatus'}}, 'status', #'TStatus'{}}]}
;

struct_info_ext(_) -> erlang:error(function_clause).

struct_names() ->
  ['TTypeQualifierValue', 'TTypeQualifiers', 'TPrimitiveTypeEntry', 'TArrayTypeEntry', 'TMapTypeEntry', 'TStructTypeEntry', 'TUnionTypeEntry', 'TUserDefinedTypeEntry', 'TTypeEntry', 'TTypeDesc', 'TColumnDesc', 'TTableSchema', 'TBoolValue', 'TByteValue', 'TI16Value', 'TI32Value', 'TI64Value', 'TDoubleValue', 'TStringValue', 'TColumnValue', 'TRow', 'TBoolColumn', 'TByteColumn', 'TI16Column', 'TI32Column', 'TI64Column', 'TDoubleColumn', 'TStringColumn', 'TBinaryColumn', 'TColumn', 'TRowSet', 'TStatus', 'THandleIdentifier', 'TSessionHandle', 'TOperationHandle', 'TOpenSessionReq', 'TOpenSessionResp', 'TCloseSessionReq', 'TCloseSessionResp', 'TGetInfoValue', 'TGetInfoReq', 'TGetInfoResp', 'TExecuteStatementReq', 'TExecuteStatementResp', 'TGetTypeInfoReq', 'TGetTypeInfoResp', 'TGetCatalogsReq', 'TGetCatalogsResp', 'TGetSchemasReq', 'TGetSchemasResp', 'TGetTablesReq', 'TGetTablesResp', 'TGetTableTypesReq', 'TGetTableTypesResp', 'TGetColumnsReq', 'TGetColumnsResp', 'TGetFunctionsReq', 'TGetFunctionsResp', 'TGetOperationStatusReq', 'TGetOperationStatusResp', 'TCancelOperationReq', 'TCancelOperationResp', 'TCloseOperationReq', 'TCloseOperationResp', 'TGetResultSetMetadataReq', 'TGetResultSetMetadataResp', 'TFetchResultsReq', 'TFetchResultsResp', 'TGetDelegationTokenReq', 'TGetDelegationTokenResp', 'TCancelDelegationTokenReq', 'TCancelDelegationTokenResp', 'TRenewDelegationTokenReq', 'TRenewDelegationTokenResp'].

enum_info('TProtocolVersion') ->
  [
    {'HIVE_CLI_SERVICE_PROTOCOL_V1', 0},
    {'HIVE_CLI_SERVICE_PROTOCOL_V2', 1},
    {'HIVE_CLI_SERVICE_PROTOCOL_V3', 2},
    {'HIVE_CLI_SERVICE_PROTOCOL_V4', 3},
    {'HIVE_CLI_SERVICE_PROTOCOL_V5', 4},
    {'HIVE_CLI_SERVICE_PROTOCOL_V6', 5},
    {'HIVE_CLI_SERVICE_PROTOCOL_V7', 6},
    {'HIVE_CLI_SERVICE_PROTOCOL_V8', 7}
  ];

enum_info('TTypeId') ->
  [
    {'BOOLEAN_TYPE', 0},
    {'TINYINT_TYPE', 1},
    {'SMALLINT_TYPE', 2},
    {'INT_TYPE', 3},
    {'BIGINT_TYPE', 4},
    {'FLOAT_TYPE', 5},
    {'DOUBLE_TYPE', 6},
    {'STRING_TYPE', 7},
    {'TIMESTAMP_TYPE', 8},
    {'BINARY_TYPE', 9},
    {'ARRAY_TYPE', 10},
    {'MAP_TYPE', 11},
    {'STRUCT_TYPE', 12},
    {'UNION_TYPE', 13},
    {'USER_DEFINED_TYPE', 14},
    {'DECIMAL_TYPE', 15},
    {'NULL_TYPE', 16},
    {'DATE_TYPE', 17},
    {'VARCHAR_TYPE', 18},
    {'CHAR_TYPE', 19},
    {'INTERVAL_YEAR_MONTH_TYPE', 20},
    {'INTERVAL_DAY_TIME_TYPE', 21}
  ];

enum_info('TStatusCode') ->
  [
    {'SUCCESS_STATUS', 0},
    {'SUCCESS_WITH_INFO_STATUS', 1},
    {'STILL_EXECUTING_STATUS', 2},
    {'ERROR_STATUS', 3},
    {'INVALID_HANDLE_STATUS', 4}
  ];

enum_info('TOperationState') ->
  [
    {'INITIALIZED_STATE', 0},
    {'RUNNING_STATE', 1},
    {'FINISHED_STATE', 2},
    {'CANCELED_STATE', 3},
    {'CLOSED_STATE', 4},
    {'ERROR_STATE', 5},
    {'UKNOWN_STATE', 6},
    {'PENDING_STATE', 7}
  ];

enum_info('TOperationType') ->
  [
    {'EXECUTE_STATEMENT', 0},
    {'GET_TYPE_INFO', 1},
    {'GET_CATALOGS', 2},
    {'GET_SCHEMAS', 3},
    {'GET_TABLES', 4},
    {'GET_TABLE_TYPES', 5},
    {'GET_COLUMNS', 6},
    {'GET_FUNCTIONS', 7},
    {'UNKNOWN', 8}
  ];

enum_info('TGetInfoType') ->
  [
    {'CLI_MAX_DRIVER_CONNECTIONS', 0},
    {'CLI_MAX_CONCURRENT_ACTIVITIES', 1},
    {'CLI_DATA_SOURCE_NAME', 2},
    {'CLI_FETCH_DIRECTION', 8},
    {'CLI_SERVER_NAME', 13},
    {'CLI_SEARCH_PATTERN_ESCAPE', 14},
    {'CLI_DBMS_NAME', 17},
    {'CLI_DBMS_VER', 18},
    {'CLI_ACCESSIBLE_TABLES', 19},
    {'CLI_ACCESSIBLE_PROCEDURES', 20},
    {'CLI_CURSOR_COMMIT_BEHAVIOR', 23},
    {'CLI_DATA_SOURCE_READ_ONLY', 25},
    {'CLI_DEFAULT_TXN_ISOLATION', 26},
    {'CLI_IDENTIFIER_CASE', 28},
    {'CLI_IDENTIFIER_QUOTE_CHAR', 29},
    {'CLI_MAX_COLUMN_NAME_LEN', 30},
    {'CLI_MAX_CURSOR_NAME_LEN', 31},
    {'CLI_MAX_SCHEMA_NAME_LEN', 32},
    {'CLI_MAX_CATALOG_NAME_LEN', 34},
    {'CLI_MAX_TABLE_NAME_LEN', 35},
    {'CLI_SCROLL_CONCURRENCY', 43},
    {'CLI_TXN_CAPABLE', 46},
    {'CLI_USER_NAME', 47},
    {'CLI_TXN_ISOLATION_OPTION', 72},
    {'CLI_INTEGRITY', 73},
    {'CLI_GETDATA_EXTENSIONS', 81},
    {'CLI_NULL_COLLATION', 85},
    {'CLI_ALTER_TABLE', 86},
    {'CLI_ORDER_BY_COLUMNS_IN_SELECT', 90},
    {'CLI_SPECIAL_CHARACTERS', 94},
    {'CLI_MAX_COLUMNS_IN_GROUP_BY', 97},
    {'CLI_MAX_COLUMNS_IN_INDEX', 98},
    {'CLI_MAX_COLUMNS_IN_ORDER_BY', 99},
    {'CLI_MAX_COLUMNS_IN_SELECT', 100},
    {'CLI_MAX_COLUMNS_IN_TABLE', 101},
    {'CLI_MAX_INDEX_SIZE', 102},
    {'CLI_MAX_ROW_SIZE', 104},
    {'CLI_MAX_STATEMENT_LEN', 105},
    {'CLI_MAX_TABLES_IN_SELECT', 106},
    {'CLI_MAX_USER_NAME_LEN', 107},
    {'CLI_OJ_CAPABILITIES', 115},
    {'CLI_XOPEN_CLI_YEAR', 10000},
    {'CLI_CURSOR_SENSITIVITY', 10001},
    {'CLI_DESCRIBE_PARAMETER', 10002},
    {'CLI_CATALOG_NAME', 10003},
    {'CLI_COLLATION_SEQ', 10004},
    {'CLI_MAX_IDENTIFIER_LEN', 10005}
  ];

enum_info('TFetchOrientation') ->
  [
    {'FETCH_NEXT', 0},
    {'FETCH_PRIOR', 1},
    {'FETCH_RELATIVE', 2},
    {'FETCH_ABSOLUTE', 3},
    {'FETCH_FIRST', 4},
    {'FETCH_LAST', 5}
  ];

enum_info(_) -> erlang:error(function_clause).

enum_names() ->
  ['TProtocolVersion', 'TTypeId', 'TStatusCode', 'TOperationState', 'TOperationType', 'TGetInfoType', 'TFetchOrientation'].

exception_names() ->
  [].

