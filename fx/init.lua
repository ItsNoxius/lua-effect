---@meta

---# fx - Effect-style data and error flow for FiveM Lua
---
---A library inspired by Effect (https://effect.website/) that improves data flow
---and error propagation in FiveM resources. When an error is thrown in an export
---function, FiveM typically returns a generic "an error occurred in resource X"
---message. This library ensures the actual error message is properly propagated.
---
---Uses standard Lua `error()` and `assert()` for compatibility and easy migration.
---
---@module fx

local Result = require('fx.result')
local Try = require('fx.try')
local Pipeline = require('fx.pipeline')
local Exports = require('fx.exports')
local Parse = require('fx.parse')
return {
    ---Result type constructors and utilities
    ---@see fx.result
    ok = Result.ok,
    err = Result.err,
    isOk = Result.isOk,
    isErr = Result.isErr,
    unwrap = Result.unwrap,
    assertResult = Result.assert,
    unwrapOr = Result.unwrapOr,
    getErrorInfo = Result.getErrorInfo,
    map = Result.map,
    mapErr = Result.mapErr,
    andThen = Result.andThen,
    orElse = Result.orElse,

    ---Try/catch wrappers - use with error() and assert() as usual
    ---@see fx.try
    try = Try.try,
    tryCall = Try.tryCall,

    ---Pipeline/chain utilities for composable data flow
    ---@see fx.pipeline
    pipe = Pipeline.pipe,
    pipeWith = Pipeline.pipeWith,

    ---FiveM export wrappers for proper cross-resource error propagation
    ---@see fx.exports
    wrap = Exports.wrap,
    invoke = Exports.invoke,
    invokeUnwrap = Exports.invokeUnwrap,
    invokeExport = Exports.invokeExport,
    invokeExportUnwrap = Exports.invokeExportUnwrap,

    ---Error parsing - extract message and location separately
    ---@see fx.parse
    parseError = Parse.error,
}
