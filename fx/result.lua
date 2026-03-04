---@meta

---# Result Type
---
---Represents either success (Ok) or failure (Err). Errors are values, not exceptions,
---so they can be safely passed across FiveM resource boundaries.
---
---@module fx.result

local Result = {}

---Create a successful result
---@param value any The success value
---@return table { ok = true, value = value }
function Result.ok(value)
    return { ok = true, value = value }
end

---Create a failed result
---@param err string|table Error message or error object
---@return table { ok = false, error = err }
function Result.err(err)
    return { ok = false, error = err }
end

---Check if result is successful
---@param r table Result to check
---@return boolean
function Result.isOk(r)
    return type(r) == 'table' and r.ok == true
end

---Check if result is a failure
---@param r table Result to check
---@return boolean
function Result.isErr(r)
    return type(r) == 'table' and r.ok == false
end

local Parse = require('fx.parse')

---Get raw error string from a result
---@param r table Result
---@return string
local function getRawError(r)
    if type(r.error) == 'string' then
        return r.error
    end
    if type(r.error) == 'table' and r.error.message then
        return r.error.message
    end
    return tostring(r.error)
end

---Extract the error message from a result for display/logging.
---Strips trace data (file:line) for cleaner messages.
---@param r table Result
---@return string
local function getErrorMessage(r)
    return Parse.error(getRawError(r)).message
end

---Get parsed error info (message + location) from a failed result.
---@param r table Result
---@return table|nil ParsedError or nil if result is Ok
function Result.getErrorInfo(r)
    if Result.isOk(r) then
        return nil
    end
    return Parse.error(getRawError(r))
end

---Unwrap a result: return value on success, throw on failure.
---Use this when you want to re-throw with the actual error message.
---@param r table Result to unwrap
---@param level? number Stack level for error() (default 1)
---@return any The success value
function Result.unwrap(r, level)
    if Result.isOk(r) then
        return r.value
    end
    error(getErrorMessage(r), (level or 1) + 1)
end

---Assert-style unwrap: return value on success, throw on failure.
---Optional custom message is used instead of the result's error if provided.
---@param r table Result to unwrap
---@param message? string Optional custom error message
---@param level? number Stack level for error()
---@return any
function Result.assert(r, message, level)
    if Result.isOk(r) then
        return r.value
    end
    error(message or getErrorMessage(r), (level or 1) + 1)
end

---Unwrap or return a default value on failure
---@param r table Result to unwrap
---@param default any Default value when result is failure
---@return any
function Result.unwrapOr(r, default)
    if Result.isOk(r) then
        return r.value
    end
    return default
end

---Map over a successful value
---@param r table Result
---@param fn function(value): any
---@return table New result
function Result.map(r, fn)
    if Result.isOk(r) then
        return Result.ok(fn(r.value))
    end
    return r
end

---Map over an error
---@param r table Result
---@param fn function(err): string|table
---@return table New result
function Result.mapErr(r, fn)
    if Result.isErr(r) then
        return Result.err(fn(r.error))
    end
    return r
end

---Chain computations: if success, run fn on value and return its result
---@param r table Result
---@param fn function(value): table Result-returning function
---@return table
function Result.andThen(r, fn)
    if Result.isOk(r) then
        return fn(r.value)
    end
    return r
end

---Recover from failure: if error, run fn and return its result
---@param r table Result
---@param fn function(err): table Result-returning function
---@return table
function Result.orElse(r, fn)
    if Result.isErr(r) then
        return fn(r.error)
    end
    return r
end

return Result
