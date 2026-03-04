---@meta

---# Exports - FiveM cross-resource error propagation
---
---When resource A calls an export from resource B and B throws an error,
---FiveM returns a generic "an error occurred in resource X" message.
---These utilities ensure the actual error message is preserved and returned.
---
---Usage:
---  Export: exports('getUser', fx.wrap(function(userId) ... end))
---  Callback: lib.callback.register('name', fx.wrap(function(source, ...) ... end))
---  Invoke export: fx.invokeExport('myresource', 'getUser', 123)
---
---  Local function: fx.invoke(getUser, 123) — no overhead when calling fn directly
---
---@module fx.exports

local Result = require('fx.result')

local Exports = {}

---Wrap a function for use in exports or callbacks.
---Catches any throw and returns Result.err instead, so errors propagate as values
---across resource boundaries. FiveM will not log SCRIPT ERROR in the called resource.
---
---@param fn function(...): any The function (may use error/assert)
---@return function(...): any
function Exports.wrap(fn)
    return function(...)
        local ok, ret = pcall(fn, ...)
        if not ok then
            return Result.err(ret)
        end
        return ret
    end
end

---Invoke a local function and return a Result.
---Uses pcall to catch throws and convert them to Result.err with the actual message.
---
---@param fn function Function to call
---@param ... any Arguments to pass
---@return table Result
function Exports.invoke(fn, ...)
    local ok, ret1 = pcall(fn, ...)
    if not ok then
        return Result.err(ret1)
    end
    return Result.ok(ret1)
end

---Invoke a local function and unwrap the result.
---@param fn function
---@param ... any
---@return any
function Exports.invokeUnwrap(fn, ...)
    return Result.unwrap(Exports.invoke(fn, ...), 1)
end

---Invoke an export and return a Result.
---Uses pcall to catch throws and convert them to Result.err with the actual message.
---
---@param resourceName string Name of the resource
---@param exportName string Name of the export
---@param ... any Arguments to pass
---@return table Result
function Exports.invokeExport(resourceName, exportName, ...)
    local res = exports[resourceName]
    local exportFn = res and res[exportName]
    if not exportFn then
        return Result.err(('Export "%s" not found in resource "%s"'):format(exportName, resourceName))
    end

    local ok, ret1 = pcall(exportFn, res, ...)
    if not ok then
        return Result.err(ret1)
    end
    -- Export may return Result (from fx.wrap catch or explicit return) — pass through
    if type(ret1) == 'table' and (ret1.ok == true or ret1.ok == false) then
        return ret1
    end
    return Result.ok(ret1)
end

---Invoke an export and unwrap the result.
---@param resourceName string
---@param exportName string
---@param ... any
---@return any
function Exports.invokeExportUnwrap(resourceName, exportName, ...)
    return Result.unwrap(Exports.invokeExport(resourceName, exportName, ...), 1)
end

return Exports
