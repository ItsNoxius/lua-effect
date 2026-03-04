---@meta

---# Try - Wrapping functions that may error
---
---Wraps code that uses `error()` and `assert()` so that errors are caught
---and returned as Result values instead of propagating as exceptions.
---This is essential for FiveM exports where thrown errors lose their message.
---
---@module fx.try

local Result = require('fx.result')

local Try = {}

---Wrap a function so it returns a Result instead of throwing.
---Any error from `error()` or `assert()` is caught and returned as Result.err.
---
---@param fn function(...): any Function that may throw
---@return function(...): table Result
function Try.try(fn)
    return function(...)
        local args = { ... }
        local ok, value = pcall(function()
            return fn(table.unpack(args))
        end)
        if ok then
            return Result.ok(value)
        end
        -- value is the error message/object
        return Result.err(value)
    end
end

---Execute a function immediately and return a Result.
---Useful when you have a one-off block of code to wrap.
---
---@param fn function(): any
---@return table Result
function Try.tryCall(fn)
    local ok, value = pcall(fn)
    if ok then
        return Result.ok(value)
    end
    return Result.err(value)
end

return Try
